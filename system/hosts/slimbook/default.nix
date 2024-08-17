{
  pkgs,
  inputs,
  ...
}: {
  # You can import other NixOS modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    # outputs.nixosModules.example

    # Hardware
    ./disks.nix
    ./hardware-configuration.nix
    inputs.hardware.nixosModules.common-cpu-intel
    inputs.hardware.nixosModules.common-pc-ssd
    inputs.hardware.nixosModules.common-pc-laptop

    # Presets
    ../../presets/users/bazyli.nix

    # Features
    ../../features/core.nix
    ../../features/lanzaboote.nix
    ../../features/locale.nix
    ../../features/console.nix
    ../../features/greetd.nix
    ../../features/networking.nix
    ../../features/hyprland
    ../../features/audio.nix
    ../../features/filesystem.nix
    ../../features/bluetooth.nix
    ../../features/virtualisation.nix
    ../../features/logiops.nix
    ../../features/printing.nix
    ../../features/silentboot.nix
    ../../features/ddcci.nix
    ../../features/btrbk.nix
    ../../features/tlp.nix
    ../../features/upower.nix
  ];

  my = {
    configurations = {
      core.enable = true;
      lanzaboote.enable = true;
      networking.enable = true;
      console.enable = true;
      locale.enable = true;
      bluetooth.enable = true;
      audio.enable = true;
      ddcci.enable = true;
      filesystem.enable = true;
      printing.enable = true;
      silentboot.enable = true;
      virtualisation.enable = true;
    };
    programs = {
      hyprland.enable = true;
      btrbk.enable = true;
      greetd.enable = true;
      logiops.enable = true;
      tlp.enable = true;
      upower.enable = true;
    };
  };

  networking.hostName = "slimbook";

  programs.fish.enable = true;
  programs.light.enable = true;

  services.hardware.bolt.enable = true;
  services.systemd-lock-handler.enable = true; # Required for `lock.target` in user's systemd

  security.pam.services.hyprlock.text = "auth include login"; # Required by `hyprlock`
  security.polkit.enable = true;
}
