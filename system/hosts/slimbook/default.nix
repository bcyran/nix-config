{pkgs, ...}: {
  # You can import other NixOS modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    # outputs.nixosModules.example

    # Or modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # Hardware
    ./disks.nix
    ./hardware-configuration.nix

    # Presets
    ../../presets/core.nix
    ../../presets/users/bazyli.nix

    # Features
    ../../features/lanzaboote.nix
    ../../features/locale.nix
    ../../features/console.nix
    ../../features/greetd.nix
    ../../features/swaylock.nix
    ../../features/xdg-portal.nix
    ../../features/pipewire.nix
    ../../features/filesystem.nix
    ../../features/bluetooth.nix
    ../../features/virtualisation.nix
    ../../features/logiops.nix
    ../../features/printing.nix
    ../../features/silentboot.nix
    ../../features/ddcci.nix
  ];

  networking.hostName = "slimbook";
  networking.networkmanager.enable = true;

  programs.fish.enable = true;
  programs.hyprland.enable = true;
  programs.light.enable = true;
  services.hardware.bolt.enable = true;

  environment.systemPackages = with pkgs; [
    neovim
  ];
}
