#!/usr/bin/env bash

set -euo pipefail

#
# FRAMEWORK
#
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
ENDCOLOR='\e[0m'

log_info() {
  echo -e "${BLUE}$*${ENDCOLOR}" >&2
}
log_success() {
  echo -e "${GREEN}$*${ENDCOLOR}" >&2
}
log_err() {
  echo -e "${RED}$*${ENDCOLOR}" >&2
}
log_warn() {
  echo -e "${YELLOW}$*${ENDCOLOR}" >&2
}

#
# SCRIP SETUP & CHECKS
#
tmpdir=$(mktemp -d)

bail() {
  rm -rf "${tmpdir}"
  log_err "ERROR! Installer failed!"
}
trap bail ERR

script_path=$(realpath "$0")
script_name=$(basename "${script_path}")

usage() {
  echo "\
Usage: ${script_name} <action> <target ip> <target hostname> <target username>

Actions:
  hardware - generate hardware configuration on the target machine and fetch it
  bootstrap - install the minimal installer system on the target machine
  keys - generate SSH keys on the target system and fetch them
  secureboot - generate and enroll Secure Boot keys on the target system
  install - install the actual system
  home - install the home configuration" >&2
}

if [[ $# != 4 ]]; then
  usage
  exit 1
fi

#
# ARGS
#
action="${1:-}"
target_ip="${2:-}"
target_hostname="${3:-}"
target_user="${4:-}"

#
# VARS
#
config_dir=$(realpath "$(dirname "${script_path}")/..")
config_dir_name=$(basename "${config_dir}")
tmp_config_dir="/tmp/${config_dir_name}"
target_home="/home/${target_user}"
target_config_dir="${target_home}/${config_dir_name}"
artifacts_dir="${PWD}/installer/${target_hostname}"

#
# UTILITIES
#
ssh_opts=(-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=QUIET)

# $1 - user, $2 ... $n - args
ssh_cmd() {
  ssh "${ssh_opts[@]}" -t "$1@${target_ip}" "${@:2}" bash
}

# $1 - user, $2 - source, $3 - destination
scp_cmd() {
  scp "${ssh_opts[@]}" "$1@${target_ip}:$2" "$3"
}

# $1 - user
copy_id() {
  ssh-copy-id "${ssh_opts[@]}" -i ~/.ssh/id_ed25519 "$1@${target_ip}"
}

# $1 - user
copy_id_via_root() {
  # shellcheck disable=SC2002,SC2029
  cat ~/.ssh/id_ed25519.pub \
    | ssh "${ssh_opts[@]}" "root@${target_ip}" \
      "sudo -u ${1} bash -c 'mkdir -p ~/.ssh; chmod 700 ~/.ssh; tee -a ~/.ssh/authorized_keys'"
}

# $1 = user, $2 = source, $3 = destination
sync_dir() {
  rsync -a --info=progress2 --filter=':- .gitignore' -e "ssh ${ssh_opts[*]}" "$2" "$1@${target_ip}:$3"
}

#
# HARDWARE
#
hardware() {
  log_info "Ensuring this host is authorized on the target machine"
  copy_id nixos

  log_info "Ensuring configuration is generated on the target machine"
  local tmp_config_dir="/tmp/generated_config"
  ssh_cmd nixos << EOF
    if [[ ! -d ${tmp_config_dir} ]]; then
      mkdir -p "${tmp_config_dir}"
      nixos-generate-config --no-filesystems --root "${tmp_config_dir}"
      echo "Generated new config"
    else
      echo "Config already exists"
    fi
EOF

  log_info "Fetching hardware-configuration.nix from the target machine"
  mkdir -p "${artifacts_dir}"
  scp_cmd nixos "${tmp_config_dir}/etc/nixos/hardware-configuration.nix" "${artifacts_dir}/hardware-configuration.nix"

  log_info "Configuration ready in ${artifacts_dir}"
  log_success "Finished fetching the hardware configuration"
}

#
# BOOSTRAP
#
bootstrap() {
  local extra_files_dir
  extra_files_dir="${tmpdir}/installer_extra_files"

  log_info "Staring the installation"
  mkdir -p "${extra_files_dir}/root/.ssh"
  cat ~/.ssh/id_ed25519.pub > "${extra_files_dir}/root/.ssh/authorized_keys"
  nix run github:nix-community/nixos-anywhere/69ad3f4a50cfb711048f54013404762c9a8e201e -- \
    --no-reboot \
    --extra-files "${extra_files_dir}" \
    --flake ".#${target_hostname}-installer" \
    "nixos@${target_ip}"

  log_info "Your public key is deployed to root's authorized_keys on the target machine"

  log_success "Installer bootstrapping finished"
}

#
# KEYS
#
keys() {
  log_info "Deploying SSH authorized_keys for ${target_user} on the target machine"
  copy_id_via_root "${target_user}"

  log_info "Ensuring ${target_user} on the target machine has an SSH key pair"
  ssh_cmd "${target_user}" << EOF
    if [[ ! -f ${target_home}/.ssh/id_ed25519 ]]; then
      ssh-keygen \
        -t ed25519 \
        -f "${target_home}/.ssh/id_ed25519" \
        -C "${target_user}@${target_hostname}" \
        -N ''
    fi
EOF

  mkdir -p "${artifacts_dir}"

  log_info "Fetching root's public key from the target machine"
  scp_cmd root /etc/ssh/ssh_host_ed25519_key.pub "${artifacts_dir}/ssh_host_ed25519_key.pub"

  log_info "Fetching ${target_user}'s public key from the target machine"
  scp_cmd "${target_user}" .ssh/id_ed25519.pub "${artifacts_dir}/id_ed25519.pub"

  log_info "Public keys ready in ${artifacts_dir}"

  log_info "Host keys:"
  cat "${artifacts_dir}/ssh_host_ed25519_key.pub"
  ssh-to-age -i "${artifacts_dir}/ssh_host_ed25519_key.pub"

  log_info "User keys:"
  cat "${artifacts_dir}/id_ed25519.pub"
  ssh-to-age -i "${artifacts_dir}/id_ed25519.pub"

  log_success "SSH keys setup finished"
}

#
# SECUREBOOT
#
secureboot() {
  log_info "Ensuring Secure Boot keys are present"
  ssh_cmd root << EOF
    if [[ ! -d /etc/secureboot ]]; then
      sbctl create-keys
      sbctl enroll-keys --microsoft
      echo "Secure Boot keys created & enrolled"
    else
      echo "Secure Boot keys already present"
    fi
EOF

  log_success "Secure Boot setup finished"
}

#
# INSTALL
#
install() {
  log_info "Syncing the configuration to ${target_config_dir}"
  sync_dir "${target_user}" "${config_dir}/" "${target_config_dir}"

  log_info "Adding local SSH keys to ssh-agent for remote use"
  ssh-add

  log_info "Ensuring github.com fingerprint is added to known hosts"
  ssh_cmd root << EOF
    if [[ ! -f ~/.ssh/known_hosts ]]; then
      ssh-keyscan -t ssh-ed25519 github.com > ~/.ssh/known_hosts
      echo "Added github.com fingerprint to know hosts"
    else
      echo "Known hosts file already exists."
    fi
EOF

  log_info "Rebuilding the system"
  # Copying the config to the temporary directory because we run rebuild as a root
  # so we will mess up git files permissions.
  ssh_cmd root -o ForwardAgent=yes << EOF
    cp -r "${target_config_dir}" "${tmp_config_dir}"
    cd "${tmp_config_dir}"
    nixos-rebuild switch --flake .
EOF

  log_success "Installation finished"
}

#
# HOME
#
home() {
  log_info "Rebuilding user's home"
  ssh_cmd "${target_user}" -o ForwardAgent=yes << EOF
    cd "${target_config_dir}"
    nix run nixpkgs#home-manager -- switch --flake .
EOF

  log_success "Home installation finished"
}

#
# ENTRYPOINT
#
case "${action}" in
  hardware)
    hardware
    ;;
  bootstrap)
    bootstrap
    ;;
  keys)
    keys
    ;;
  secureboot)
    secureboot
    ;;
  install)
    install
    ;;
  home)
    home
    ;;
  --help | -h)
    usage
    ;;
  *)
    log_err "Invalid action: ${action}."
    usage
    exit 1
    ;;
esac
