{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (config.colorScheme) palette;
  cfg = config.my.programs.kitty;

  kittyThemeFile = pkgs.writeText "${config.colorScheme.slug}.conf" ''
    background #${palette.base00}
    foreground #${palette.base05}
    selection_background #${palette.base02}
    selection_foreground #${palette.base05}

    cursor #${palette.base05}
    cursor_text_color #${palette.base00}

    url_color #${palette.base0D}

    color0 #${palette.base00}
    color1 #${palette.base08}
    color2 #${palette.base0B}
    color3 #${palette.base0A}
    color4 #${palette.base0D}
    color5 #${palette.base0E}
    color6 #${palette.base0C}
    color7 #${palette.base05}
    color8 #${palette.base02}
    color9 #${palette.base12}
    color10 #${palette.base14}
    color11 #${palette.base13}
    color12 #${palette.base16}
    color13 #${palette.base17}
    color14 #${palette.base15}
    color15 #${palette.base07}
  '';
in {
  options.my.programs.kitty.enable = lib.mkEnableOption "kitty";

  config = lib.mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      font = {
        name = builtins.elemAt config.fonts.fontconfig.defaultFonts.monospace 0;
        size = 14;
      };
      shellIntegration.enableFishIntegration = true;
      keybindings = {
        "ctrl+shift+d" = "scroll_page_down";
        "ctrl+shift+u" = "scroll_page_up";
        "cltl+shift+g" = "scroll_end";
        "cltl+shift+m" = "scroll_to_prompt 1";
        "cltl+shift+," = "scroll_to_prompt -1";
        "cltl+shift+i" = "kitten unicode_input";
      };
      extraConfig = ''
        include ${kittyThemeFile}

        window_margin_width 5
        cursor_trail 1
        scrollback_lines 10000
        disable_ligatures cursor
      '';
    };
  };
}
