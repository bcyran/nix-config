{pkgs, ...}: {
  # You can import other NixOS modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    # outputs.nixosModules.example

    # Or modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # Hardware
    ./hardware-configuration.nix

    # Presets
    ../../presets/core.nix
    ../../presets/users/bazyli.nix

    # Features
    ../../features/greetd.nix
    ../../features/console.nix
    ../../features/xdg-portal.nix
    ../../features/pipewire.nix
    ../../features/filesystem.nix
    ../../features/bluetooth.nix
  ];

  networking.hostName = "nixtest";

  boot.loader.systemd-boot.enable = true;
  networking.networkmanager.enable = true;

  i18n.defaultLocale = "pl_PL.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pl_PL.UTF-8";
    LC_IDENTIFICATION = "pl_PL.UTF-8";
    LC_MEASUREMENT = "pl_PL.UTF-8";
    LC_MONETARY = "pl_PL.UTF-8";
    LC_NAME = "pl_PL.UTF-8";
    LC_NUMERIC = "pl_PL.UTF-8";
    LC_PAPER = "pl_PL.UTF-8";
    LC_TELEPHONE = "pl_PL.UTF-8";
    LC_TIME = "pl_PL.UTF-8";
  };

  programs.fish.enable = true;
  programs.hyprland.enable = true;
  programs.light.enable = true;

  environment.systemPackages = with pkgs; [
    gcc
    inotifyTools
    neovim
  ];

  security.pam.services.swaylock = {};

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
