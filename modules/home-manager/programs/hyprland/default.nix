{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.my.programs.hyprland;
  envVars = {
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORM = "wayland";
    HYPRCURSOR_THEME = "phinger-cursors-dark-hyprcursor";
    HYPRCURSOR_SIZE = "24";
  };
in {
  options.my.programs.hyprland = {
    enable = lib.mkEnableOption "hyprland";

    execWrapper = lib.mkOption {
      type = lib.types.str;
      default = "uwsm app --";
      description = "Command prefix to wrap hyprland execution with.";
    };

    withUWSM = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to wrap hyprland execution with uwsm.";
    };
  };

  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = false;
      settings.env = lib.mapAttrsToList (name: value: "${name},${value}") envVars;
      plugins = with pkgs.hyprlandPlugins; [
        hy3
      ];
    };

    programs.hyprcursor-phinger.enable = true;
    home = {
      packages = [pkgs.hyprcursor];
      sessionVariables = envVars;
    };

    xresources.properties = {
      "Xft.dpi" = 120;
      "Xft.autohint" = 0;
      "Xft.lcdfilter" = "lcddefault";
      "Xft.hintstyle" = "hintfull";
      "Xft.hinting" = 1;
      "Xft.antialias" = 1;
      "Xft.rgba" = "rgb";
    };
  };

  imports = [
    ./binds.nix
    ./settings.nix
    ./rules.nix
  ];
}
