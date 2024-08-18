{
  config,
  lib,
  ...
}: let
  inherit (config.colorScheme) palette;
  cfg = config.my.programs.alacritty;
in {
  options.my.programs.alacritty.enable = lib.mkEnableOption "alacritty";

  config = lib.mkIf cfg.enable {
    programs.alacritty = {
      enable = true;
      settings = {
        colors = {
          primary = {
            background = "#${palette.base00}";
            foreground = "#${palette.base05}";
          };
          normal = {
            black = "#${palette.base00}";
            red = "#${palette.base08}";
            green = "#${palette.base0B}";
            yellow = "#${palette.base0A}";
            blue = "#${palette.base0D}";
            magenta = "#${palette.base0E}";
            cyan = "#${palette.base0C}";
            white = "#${palette.base05}";
          };
          bright = {
            black = "#${palette.base02}";
            red = "#${palette.base12}";
            green = "#${palette.base14}";
            yellow = "#${palette.base13}";
            blue = "#${palette.base16}";
            magenta = "#${palette.base17}";
            cyan = "#${palette.base15}";
            white = "#${palette.base07}";
          };
        };
        env = {
          TERM = "xterm-256color";
          WINIT_X11_SCALE_FACTOR = "1";
        };
        font = {
          size = 14;
          normal.family = builtins.elemAt config.fonts.fontconfig.defaultFonts.monospace 0;
        };
        window.padding = {
          x = 5;
          y = 5;
        };
      };
    };
  };
}
