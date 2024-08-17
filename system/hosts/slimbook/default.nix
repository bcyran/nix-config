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
    ../../presets/core.nix
    ../../presets/users/bazyli.nix

    # Features
    ../../features/lanzaboote.nix
    ../../features/locale.nix
    ../../features/console.nix
    ../../features/utilities.nix
    ../../features/greetd.nix
    ../../features/networking.nix
    ../../features/hyprland
    ../../features/lock.nix
    ../../features/pipewire.nix
    ../../features/filesystem.nix
    ../../features/bluetooth.nix
    ../../features/virtualisation.nix
    ../../features/logiops.nix
    ../../features/printing.nix
    ../../features/silentboot.nix
    ../../features/ddcci.nix
    ../../features/btrbk.nix
    ../../features/tlp.nix
    ../../features/polkit.nix
    ../../features/upower.nix
  ];

  my = {
    configurations = {
      bluetooth.enable = true;
    };
    programs = {
      hyprland.enable = true;
    };
  };

  networking.hostName = "slimbook";

  programs.fish.enable = true;
  programs.light.enable = true;
  services.hardware.bolt.enable = true;

  environment.systemPackages = with pkgs; [
    neovim
  ];
}
