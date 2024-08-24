{
  inputs,
  pkgs,
  my,
  lib,
  config,
  ...
}: let
  cfg = config.my.configurations.core;
in {
  options.my.configurations.core.enable = lib.mkEnableOption "core";

  config = lib.mkIf cfg.enable {
    nixpkgs = {
      overlays = [
        my.overlays.modifications
      ];
      config = {
        allowUnfree = true;
      };
    };

    nix = {
      settings = {
        experimental-features = "nix-command flakes";
        auto-optimise-store = true;
        warn-dirty = false;
        trusted-substituters = [
          "https://devenv.cachix.org"
        ];
        trusted-public-keys = [
          "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
        ];
      };
      # TODO: Use something like `agenix` or `sops` instead of providing GitHub API key in the
      #       `nix-local.conf` file.
      extraOptions = ''
        !include nix-local.conf
      '';

      # This will add each flake input as a registry
      # To make nix3 commands consistent with your flake
      registry = (lib.mapAttrs (_: flake: {inherit flake;})) ((lib.filterAttrs (_: lib.isType "flake")) inputs);

      # This will additionally add your inputs to the system's legacy channels
      # Making legacy nix commands consistent as well, awesome!
      nixPath = ["/etc/nix/path"];
    };

    environment.etc =
      lib.mapAttrs'
      (name: value: {
        name = "nix/path/${name}";
        value.source = value.flake;
      })
      config.nix.registry;

    programs.fish.enable = true;

    environment.systemPackages = with pkgs; [
      e2fsprogs
      lsof
      lm_sensors
      curl
      usbutils
      pciutils
      gparted
      neovim
    ];

    boot.tmp.cleanOnBoot = !config.boot.tmp.useTmpfs;

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    system.stateVersion = "23.11";
  };
}
