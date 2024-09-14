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

ssh_user_cmd="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=QUIET -t ${target_user}@${target_ip}"
ssh_root_cmd="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=QUIET -t root@${target_ip}"
scp_cmd="scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

#
# BOOSTRAP
#
bootstrap() {
  local extra_files_dir
  extra_files_dir="${tmpdir}/extra-files"

  log_info "Preparing SSH authorized keys keys for the target"
  mkdir -p "${extra_files_dir}/root/.ssh"
  cat ~/.ssh/id_ed25519.pub > "${extra_files_dir}/root/.ssh/authorized_keys"

  log_info "Staring the installation"
  nix run github:nix-community/nixos-anywhere/69ad3f4a50cfb711048f54013404762c9a8e201e -- --extra-files "${extra_files_dir}" --flake ".#${target_hostname}-installer" "nixos@${target_ip}"

  log_success "Installer bootstrapping finished"
}

#
# KEYS
#
keys() {
  local artifacts_dir
  artifacts_dir="${PWD}/installer/${target_hostname}"
  mkdir -p "${artifacts_dir}"

  log_info "Ensuring ${target_user} has the same authorized SSH keys as root"

  ${ssh_root_cmd} bash << EOF
    if [[ ! -d ${target_home}/.ssh ]]; then
      mkdir -p ${target_home}/.ssh
      chown ${target_user} ${target_home}/.ssh
      chmod 700 ${target_home}/.ssh
      echo "${target_home}/.ssh created"
    else
      echo "${target_home}/.ssh already exists"
    fi
EOF

  ${ssh_root_cmd} bash << EOF
    cp -v /root/.ssh/authorized_keys ${target_home}/.ssh/authorized_keys
    chown ${target_user} ${target_home}/.ssh/authorized_keys
EOF

  log_info "Ensuring ${target_user} has an SSH key pair"

  ${ssh_user_cmd} bash << EOF
    if [[ ! -f ${target_home}/.ssh/id_ed25519 ]]; then
      ssh-keygen -t ed25519 -f ${target_home}/.ssh/id_ed25519 -C ${target_user}@${target_hostname} -N ''
    fi
EOF

  log_info "Fetching public SSH keys from target"

  ${scp_cmd} "${target_user}@${target_ip}":.ssh/id_ed25519.pub "${artifacts_dir}/id_ed25519.pub"
  ${scp_cmd} "root@${target_ip}":/etc/ssh/ssh_host_ed25519_key.pub "${artifacts_dir}/ssh_host_ed25519_key.pub"

  log_info "Public keys ready in ${artifacts_dir}"
  log_info "User's keys:"
  cat "${artifacts_dir}/id_ed25519.pub"
  ssh-to-age -i "${artifacts_dir}/id_ed25519.pub"
  log_info "Host's keys:"
  cat "${artifacts_dir}/ssh_host_ed25519_key.pub"
  ssh-to-age -i "${artifacts_dir}/ssh_host_ed25519_key.pub"

  log_success "SSH keys setup finished"
}

#
# SECUREBOOT
#
secureboot() {
  log_info "Ensuring Secure Boot keys are present"
  ${ssh_root_cmd} << EOF
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
  log_info "Copying the configuration to ${target_config_dir}"
  ${scp_cmd} -r "${config_dir}" "${target_user}@${target_ip}:${target_config_dir}"

  log_info "Adding local SSH keys to ssh-agent for remote use"
  ssh-add

  log_info "Ensuring github.com fingerprint is added to known hosts"
  ${ssh_root_cmd} << EOF
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
  ${ssh_root_cmd} -o ForwardAgent=yes << EOF
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
  ${ssh_user_cmd} -o ForwardAgent=yes << EOF
    cd "${target_config_dir}"
    nix run nixpkgs#home-manager -- switch --flake .
EOF

  log_success "Home installation finished"
}

#
# ENTRYPOINT
#
case "${action}" in
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
