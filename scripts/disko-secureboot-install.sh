#!/usr/bin/env bash

set -euo pipefail

RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
ENDCOLOR='\e[0m'

MOUNT_DIR='/mnt'
INSTALLER_TMP_DIR="${MOUNT_DIR}/tmp"
SECUREBOOT_DIR="${MOUNT_DIR}/etc/secureboot"

err_report() {
  echo -e "${RED}ERROR!${ENDCOLOR} The installation failed!" >&2
}
trap err_report ERR

script_path=$(realpath "$0")
script_name=$(basename "${script_path}")
flake_dir=$(realpath "$(dirname "${script_path}")/..")
target_host="${1:-}"
target_user="${2:-bazyli}"
target_config_dir="${MOUNT_DIR}/home/${target_user}/nixos-config"

if [[ "$(id -u)" -eq 0 ]]; then
  echo -e "${RED}ERROR!${ENDCOLOR} ${script_name} should be run as a regular user!" >&2
  exit 1
fi

if [[ -z "${target_host}" ]]; then
  echo "Usage: ${script_name} hostname [username]" >&2
  exit 1
fi

echo -e "${YELLOW}WARNING!${ENDCOLOR} This will wipe the disk and reinstall the system!" >&2
read -r -p "Do you want to proceed? (type YES to continue): "
if [[ ${REPLY} != "YES" ]]; then
  echo "Aborted."
  exit 1
fi

echo -e "${BLUE}Wiping and partitioning the disk${ENDCOLOR}"
sudo disko --mode disko "${flake_dir}/hosts/${target_host}/nixos/disks.nix"

echo -e "${BLUE}Creating secureboot keys${ENDCOLOR}"
sudo mkdir -p ${SECUREBOOT_DIR}
sudo sbctl create-keys -d ${SECUREBOOT_DIR} -e ${SECUREBOOT_DIR}/keys

# Apparently my config is too big to be built in tmpfs mounted /nix on some machines
echo -e "${BLUE}Installing NixOS${ENDCOLOR}"
sudo mkdir ${INSTALLER_TMP_DIR}
sudo TMPDIR=${INSTALLER_TMP_DIR} nixos-install --flake ".#${target_host}"

echo -e "${BLUE}Copying the config to the ${target_user}'s home directory${ENDCOLOR}"
mkdir -p "${target_config_dir}"
rsync -a "${flake_dir}/" "${target_config_dir}"

echo -e "${GREEN}All done!${ENDCOLOR}"
