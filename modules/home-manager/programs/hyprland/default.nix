{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (config.colorScheme) palette;
  cfg = config.my.programs.hyprland;
  toLua = lib.generators.toLua {};

  envVars = {
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    HYPRCURSOR_THEME = "phinger-cursors-dark-hyprcursor";
    HYPRCURSOR_SIZE = "24";
  };

  generated = {
    inherit (cfg) execWrapper withUWSM withNoctalia;
    fontFamily = builtins.elemAt config.fonts.fontconfig.defaultFonts.sansSerif 0;
    palette = {
      inherit (palette) accentPrimary base00 base05 base10;
    };
    env = envVars;
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

    withNoctalia = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to use Noctalia shell integration for Hyprland.";
    };
  };

  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      systemd = {
        enable = !cfg.withUWSM;
        enableXdgAutostart = !cfg.withUWSM;
      };
      configType = "lua";
      extraLuaFiles = {
        # Nix -> Lua bridge, same pattern as our Neovim config: a pure-data
        # module with the handful of values computed from Nix (colors, fonts,
        # feature flags). Not auto-loaded; hand-written modules `require` it
        # themselves when they need a value.
        "config.generated" = {
          content = "return ${toLua generated}\n";
          autoLoad = false;
        };

        "config.env" = ./files/config/env.lua;
        "config.input" = ./files/config/input.lua;
        "config.look" = ./files/config/look.lua;
        "config.animations" = ./files/config/animations.lua;
        "config.binds" = ./files/config/binds.lua;
        "config.rules" = ./files/config/rules.lua;
        "config.autostart" = ./files/config/autostart.lua;
        "config.monitors" = ./files/config/monitors.lua;
      };
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
}
