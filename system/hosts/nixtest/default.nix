{
  pkgs,
  lib,
  ...
}: {
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
  ];

  networking.hostName = "nixtest";

  boot = {
    initrd.systemd.enable = true;
    loader.systemd-boot.enable = lib.mkForce false;
    bootspec.enable = true;
    lanzaboote = {
      enable = true;
      pkiBundle = "/etc/secureboot";
    };
  };
  networking.networkmanager.enable = true;

  programs.fish.enable = true;
  programs.hyprland.enable = true;
  programs.light.enable = true;

  environment.systemPackages = with pkgs; [
    neovim
  ];

  # This setups a SSH server. Very important if you're setting up a headless system.
  # Feel free to remove if you don't need it.
  services.openssh = {
    enable = true;
    settings = {
      # Forbid root login through SSH.
      PermitRootLogin = "no";
    };
  };
}
