{config, ...}: let
  inherit (config.colorscheme) palette;
  font = "Roboto Condensed";
in {
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
          font_family = font;
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
          placeholder_text = ''<span font_family="${font}" font_style="italic">$PROMPT</span>'';
          fail_text = ''<span font_family="${font}" font_style="italic">$FAIL <b>($ATTEMPTS)</b></span>'';
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
}
