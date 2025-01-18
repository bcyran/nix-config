<h1 align="center">❄️ Bazyli's Nix config ✨</h1>

> Hi!
> This repo contains NixOS and Home Manager configurations for all my machines.
> Be warned that it's not intended to be used directly by anyone other than me and likely wouldn't work if you tried.
> However, please feel free to look around, learn, and copy as much as you want.
> Happy nixing!

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

<table width="100%">
  <tr width="100%">
    <td colspan="2" align="center" width="100%">
      <img src="./docs/images/screenshot_1.png" alt="Screenshot of desktop with tiled terminal windows running neovim, neofetch and eza" />
      <i>Visible: hyprland, waybar, alacritty, neovim, neofetch, eza.</i>
    </td>
  </tr>
  <tr width="100%">
    <td align="center" width="50%">
      <img src="./docs/images/screenshot_2.png" alt="Screenshot of desktop with floating terminal window and sway notification center" />
      <i>Visible: hyprland, waybar, alacritty, figlet, lolcat, swaync.</i>
    </td>
    <td align="center" width="50%">
      <img src="./docs/images/screenshot_3.png" alt="Screenshot of desktop with tiled firefox and terminal emulator running btop windows" />
      <i>Visible: hyprland, waybar, firefox, alacritty, btop.</i>
    </td>
  </tr>
</table>

## Structure
- `hosts` - Configurations for specific machines.
  - `<hostname>`
    - `common` - Configurations used by both NixOS and Home Manager.
      - `user.nix` - Definitions of options containing my user account details.
        Those are imported by both NixOS and Home Manager.
        This way the values are accessible both for home and system configurations and always in sync.
    - `home-manager`
      - `bazyli.nix` - Definitions of Home Manager options.
        I'm mostly defining custom options declared in `modules`.
    - `nixos`
      - `disks.nix` - Disks, partitions and filesystems defined using `disko`.
      - `hardware-configuration.nix` - Generated hardware configuration for the machine.
      - `configuration.nix` - Definitions of NixOS options.
        I'm mostly defining custom options declared in `modules`.
      - `*.nix` - More definitions of NixOS options which are distinct enough to be extracted from `configuration.nix`.
- `lib` - Custom helpers, used in many places or generic enough to be extracted here.
- `modules` - Modules containing declarations of all my custom options.
  - `common` - Declarations of options imported by both NixOS and Home Manager.
    See `hosts/<hostname>/common` for those options' definitions.
  - `home-manager`
    - `configurations` - Modules with configurations not directly related to specific programs.
    - `options` - Modules containing only options' declarations.
      Those modules do not contain the `config` section at all.
      The values of those options are consumed by other modules.
    - `presets` - Modules defining presets which enable a bunch of options declared in other modules at once.
      E.g. `cli`, `desktop`, `hyprland`.
    - `programs` - Modules with configurations related to specific programs.
      Usually each module configures a single program.
  - `nixos`
    - `configurations` - Same as in `home-manager`.
    - `options` - Same as in `home-manager`.
    - `presets` - Same as in `home-manager`.
    - `programs` - Same as in `home-manager`.
    - `services` - Modules with configurations related to services.
      For me a "service" is a program which servers something to different machines so those modules are used almost exclusively on servers.
      Note that it's a different definition of a "service" than what `nixpgs` modules use.
- `overlays` - Custom overlays modifying `nixpkgs`.
  I barely use this.
- `pkgs` - Custom packages.
  Those might be my personal scripts / programs, packages I found on the internet which are not in `nixpkgs`, or packages I intend to upstream into `nixpkgs`.
- `flake.nix` - Flake entrypoint.
  Exposes all the modules and configurations defined in the flake and allows them to be imported by other flakes.

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
