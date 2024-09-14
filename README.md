# nix-config

My NixOS and Home Manager config.

## Features

- Declarative disk partitioning with [disko](https://github.com/nix-community/disko).
- LUKS full disk encryption and auto unlocking with TPM.
- Secure Boot with [Lanzaboote](https://github.com/nix-community/lanzaboote).
- BTRFS with home directory snapshots.
- Secrets provisioning with [sops-nix](https://github.com/Mic92/sops-nix).
  The secrets are stored in a separate, private repo.
- The entire configuration is modularized and exported from the flake.
  This allows using selected (or all) parts in other flakes.
- Semi-automated installation.

## Screenshots

![Screenshot of desktop with tiled terminal windows running neovim, neofetch and eza](./docs/images/screenshot_1.png)
![Screenshot of desktop with floating terminal window and sway notification center](./docs/images/screenshot_2.png)
![Screenshot of desktop with tiled firefox and terminal emulator running btop windows](./docs/images/screenshot_3.png)

## Installation

See the [Installation instruction](/docs/installation.md).

## Credits & resources

I used this to learn about NixOS and might have copied some stuff from there.

### Configs

- [Misterio77/nix-starter-configs](https://github.com/Misterio77/nix-starter-configs)
- [Misterio77/nix-config](https://github.com/Misterio77/nix-config)
- [fufexan/dotfiles](https://github.com/fufexan/dotfiles)
- [jnsgruk/nixos-config](https://github.com/jnsgruk/nixos-config)
- [EmergentMind/nix-config](https://github.com/EmergentMind/nix-config)
- [hlissner/dotfiles](https://github.com/hlissner/dotfiles)
- [gvolpe/nix-config](https://github.com/gvolpe/nix-config)
- [pinpox/nixos](https://github.com/pinpox/nixos)

### Posts & videos

- [Secure Boot & TPM-backed Full Disk Encryption on NixOS](https://jnsgr.uk/2024/04/nixos-secure-boot-tpm-fde/)
- [NixOS Secrets Management](https://unmovedcentre.com/posts/secrets-management/)
- [Framework and NixOS - Sops-nix Secrets Management](https://0xda.de/blog/2024/07/framework-and-nixos-sops-nix-secrets-management/#re-enabling-secure-boot)
- [Vimjoyer on YT](https://www.youtube.com/@vimjoyer)
- [EmergentMind on YT](https://www.youtube.com/@Emergent_Mind)
