{
  config,
  lib,
  ...
}:
with lib; let
  inherit (config.colorScheme) palette;
  cfg = config.my.programs.dunst;
in {
  options.my.programs.dunst.enable = mkEnableOption "dunst";

  config = mkIf cfg.enable {
    services.dunst = {
      enable = true;
      settings = {
        global = {
          monitor = 1;
          follow = "none";
          width = 350;
          height = 300;
          origin = "top-right";
          offset = "20x20";
          scale = 0;
          notification_limit = 0;
          indicate_hidden = "yes";
          shrink = "no";
          transparency = 0;
          separator_height = 2;
          padding = 8;
          horizontal_padding = 8;
          frame_width = 2;
          frame_color = "#aaaaaa";
          separator_color = "frame";
          sort = "yes";
          idle_threshold = "120";
          font = "Inter 14";
          line_height = 0;
          markup = "full";
          format = "<b>%s</b>\n%b";
          alignment = "left";
          show_age_threshold = 60;
          word_wrap = "yes";
          ellipsize = "middle";
          ignore_newline = "no";
          stack_duplicates = true;
          hide_duplicate_count = false;
          show_indicators = "no";
          icon_position = "left";
          sticky_history = "yes";
          history_length = 20;
        };
        urgency_low = {
          background = "#${palette.base00}";
          foreground = "#${palette.base05}";
          frame_color = "#${palette.accentPrimary}";
          timeout = 10;
        };
        urgency_normal = {
          background = "#${palette.base00}";
          foreground = "#${palette.base05}";
          frame_color = "#${palette.accentPrimary}";
          timeout = 10;
        };
        urgency_critical = {
          background = "#${palette.base00}";
          foreground = "#${palette.base05}";
          frame_color = "#${palette.accentPrimary}";
          timeout = 0;
        };
      };
    };
  };
}
