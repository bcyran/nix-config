{
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
        font = "Roboto Condensed 14";
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
        background = "#1e222a";
        foreground = "#abb2bf";
        frame_color = "#e5c07b";
        timeout = 10;
      };
      urgency_normal = {
        background = "#1e222a";
        foreground = "#abb2bf";
        frame_color = "#e5c07b";
        timeout = 10;
      };
      urgency_critical = {
        background = "#1e222a";
        foreground = "#abb2bf";
        frame_color = "#e5c07b";
        timeout = 0;
      };
    };
  };
}
