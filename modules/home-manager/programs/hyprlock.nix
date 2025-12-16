{
  config,
  lib,
  ...
}: let
  inherit (config.colorscheme) palette;
  cfg = config.my.programs.hyprlock;

  fontName = builtins.elemAt config.fonts.fontconfig.defaultFonts.sansSerif 0;
in {
  options.my.programs.hyprlock.enable = lib.mkEnableOption "hyprlock";

  config = lib.mkIf cfg.enable {
    programs.hyprlock = {
      enable = true;

      settings = {
        general = {
          hide_cursor = true;
        };

        background = [
          {
            monitor = "";
            color = "rgb(${palette.base00})";
          }
        ];

        label = [
          {
            monitor = "";
            text = "$TIME";
            font_size = 100;
            font_family = fontName;
            color = "rgb(${palette.base05})";
            position = "0, 50";
            valign = "center";
            halign = "center";
          }
        ];

        input-field = [
          {
            monitor = "";
            size = "300, 50";
            position = "0, -100";
            outline_thickness = 0;
            dots_center = true;
            fade_on_empty = true;
            fade_timeout = 3000;
            placeholder_text = ''<span font_family="${fontName}" font_style="italic">$PROMPT</span>'';
            fail_text = ''<span font_family="${fontName}" font_style="italic">$FAIL <b>($ATTEMPTS)</b></span>'';
            font_color = "rgb(${palette.base00})";
            inner_color = "rgb(${palette.base05})";
            check_color = "rgb(${palette.accentPrimary})";
            fail_color = "rgb(${palette.error})";
            capslock_color = "rgb(${palette.warning})";
            numlock_color = "rgb(${palette.warning})";
          }
        ];
      };
    };
  };
}
