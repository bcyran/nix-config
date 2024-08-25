{
  config,
  lib,
  ...
}: let
  inherit (config.colorscheme) palette;
  cfg = config.my.programs.zellij;
in {
  options.my.programs.zellij.enable = lib.mkEnableOption "zellij";

  config = lib.mkIf cfg.enable {
    programs.zellij = {
      enable = true;
      settings = {
        theme = "custom";
        themes.custom = {
          fg = "#${palette.base05}";
          bg = "#${palette.base00}";
          black = "#${palette.base00}";
          red = "#${palette.base08}";
          green = "#${palette.base0B}";
          yellow = "#${palette.base0A}";
          blue = "#${palette.base0D}";
          magenta = "#${palette.base0E}";
          cyan = "#${palette.base0C}";
          white = "#${palette.base05}";
          orange = "#${palette.base09}";
        };
        copy_command = "wl-copy";
        pane_frames = false;
      };
    };
  };
}
