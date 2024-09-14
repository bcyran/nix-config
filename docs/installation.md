# Installation instruction

> [!NOTE]
> This instruction is for future me and for educational purposes.
> It is not intended to enable you to install my config.
> I mean, you can try of course, but it will not work without my secrets so you will have to adjust at least that, and possibly something more.

Installation consists of two phases:

1. Using `nixos-anywhere` to install a minimal installer environment into the target machine with NixOS installer ISO booted.
2. Setting up the necessary secrets and rebuilding full system and home configuration on the target machine.

The process is mostly automated with [`./scripts/installer.sh`](../scripts/installer.sh) script.

## Preparation

1. Boot the installer ISO on the target machine.
2. Set a temporary password with `passwd`.
3. Check the IP address of the target machine with `ip a`.

## Bootstrapping

<details>
<summary>If you're installing on a new machine and don't have the hardware configuration file.</summary>

Obtain a `hardware-configuration.nix`:

```shell
./scripts/installer.sh hardware {ip} {hostname} {username}
```

Enter the temporary password if prompted.
This will copy the file into `./installer/{hostname}` directory.
Put this file in the right `./hosts` subdirectory for the target host.

</details>

Partition the disk and install the installer environment (`{hostname}-installer` in flake's `nixosConfigurations` output):

> [!CAUTION]
> This will wipe the drive on the target machine.

```shell
./scripts/installer.sh bootstrap {ip} {hostname} {username}
```

Enter the temporary password if prompted.
Set the LUKS password if prompted.

## Secure Boot

1. Reboot into UEFI interface and setup Secure Boot:
   - Enable Secure Boot.
   - Erase all keys.
   - Enable setup mode.
2. Reboot into the system.
3. Generate and enroll Secure Boot keys:

    ```shell
    ./scripts/installer.sh secureboot {ip} {hostname} {username}
    ```

## Installation

1. Generate and fetch public keys from the target machine:

    ```shell
    ./scripts/installer.sh keys {ip} {hostname} {username}
    ```

    This will copy the public key files into `./installer/{hostname}` directory.
    It will also print the keys both in SSH and in age format.
2. Use the public keys to prepare all the necessary secrets.
    Remember to:
    - Prepare new secret files for this host.
    - Update existing secret files with `sops update`.
    - Authorize the target host keys to access the secrets repo.
    - Update the secrets in the lockfile to the latest commit:

        ```shell
        nix flake lock --update-input my-secrets
        ```

3. Start the system config rebuild:

    ```shell
    ./scripts/installer.sh install {ip} {hostname} {username}
    ```

4. Start the home config rebuild:

    ```shell
    ./scripts/installer.sh home {ip} {hostname} {username}
    ```

5. Reboot.

## LUKS TPM setup

1. SSH into the target machine: `ssh {username}@{hostname}`.
2. Setup LUKS auto unlocking with TPM:

    ```shell
    sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+2+7+12 --wipe-slot=tpm2 {partition}
    ```

    Enter the LUKS password when prompted.

3. Reboot.
   The disk should be decrypted automatically.
