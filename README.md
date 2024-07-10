# dotfiles-nix

My NixOS and Home Manager config.

## Installation

### System

1. Boot the installer ISO.
2. `cd` into this repo and run `nix-shell`.
3. Run:

   ```shell
   ./scripts/disko-secureboot-install.sh ${hostname} ${username}
   ```

4. Follow the instructions. You will be asked for disk encryption password and root password.
5. Shut down the machine once the installation is completed.

### Secure Boot and TPM

1. Boot into the UEFI interface and setup Secure Boot:
   - Enable Secure Boot.
   - Erase all keys.
   - Enable setup mode.
2. Reboot into NixOS.
3. Login to TTY as root.
4. `cd` into `/home/${username}/nixos-config` and run `nix-shell`.
5. Enroll the Secure Boot keys:

   ```shell
   sbctl enroll-keys --microsoft
   ```

6. Setup LUKS auto decryption using key stored in TPM:

   ```shell
   systemd-cryptenroll --tmp2-device=auto --tpm2-pcrs=0+2+7+12 --wipe-slot=tpm2 ${partition}
   ```

   Enter the passphrase when prompted.

7. Reboot. The disk should be decrypted automatically.

### Home Manager

1. Login as root.
2. Set the user's password: `passwd ${username}`. Enter the new password twice when prompted.
3. Log out and login as the `${username}`.
4. Run `cd nixos-config` and `nix-shell`.
5. Build and switch into Home Manager configuration:

   ```shell
   home-manager switch --flake .
   ```
