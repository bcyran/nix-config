{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.my.programs.greetd;
  inherit (config.my.colorscheme) palette;
in {
  options.my.programs.greetd.enable = lib.mkEnableOption "greetd";

  config = lib.mkIf cfg.enable {
    programs.noctalia-greeter = {
      enable = true;
      settings = {
        user.default = config.my.user.name;
        keyboard.layout = "pl";
        session.default = "Hyprland (uwsm-managed)";
        idle.timeout = 300;
        appearance = {
          scheme = "Synced";
          theme_mode = "dark";
          palette = {
            primary = "#${palette.base0D}";
            on_primary = "#${palette.base00}";
            secondary = "#${palette.base0B}";
            on_secondary = "#${palette.base00}";
            tertiary = "#${palette.base0E}";
            on_tertiary = "#${palette.base00}";
            error = "#${palette.base0F}";
            on_error = "#${palette.base00}";
            surface = "#${palette.base00}";
            on_surface = "#${palette.base04}";
            surface_variant = "#${palette.base10}";
            on_surface_variant = "#${palette.base03}";
            outline = "#${palette.base01}";
            shadow = "#${palette.base11}";
            hover = "#${palette.base01}";
            on_hover = "#${palette.base05}";
          };
        };
        cursor = {
          theme = "phinger-cursors-dark";
          size = 24;
          path = "${pkgs.phinger-cursors}/share/icons";
        };
      };
    };
  };
}
