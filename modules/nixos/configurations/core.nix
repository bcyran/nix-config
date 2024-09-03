{
  inputs,
  pkgs,
  my,
  lib,
  config,
  ...
}: let
  inherit (lib) types;
  cfg = config.my.configurations.core;
in {
  options.my.configurations.core = {
    enable = lib.mkEnableOption "core";

    nixExtraOptionsFile = lib.mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Path to the file with extra Nix options.";
    };
  };

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
      };
      extraOptions =
        if (cfg.nixExtraOptionsFile != null)
        then "!include ${cfg.nixExtraOptionsFile}"
        else "";

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
      file
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
