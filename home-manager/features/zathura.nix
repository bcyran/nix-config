let
  colorBg = "#1e2030";
  colorLightBg = "#2f334d";
  colorFg = "#c8d3f5";
  colorAccent1 = "#65bcff";
  colorAccent2 = "#ffc777";
  colorAccent3 = "#c3e88d";
  colorAccent4 = "#e06c75";
in {
  programs.zathura = {
    enable = true;
    mappings = {
      "<C-i>" = "zoom in";
      "<C-o>" = "zoom out";
    };
    options = {
      window-title-basename = true;
      selection-clipboard = "clipboard";
      font = "JetBrainsMono Nerd Font normal 14";
      scroll-step = 100;

      # Colors
      default-bg = "${colorBg}";
      default-fg = "${colorFg}";
      statusbar-bg = "${colorLightBg}";
      statusbar-fg = "${colorFg}";
      inputbar-bg = "${colorBg}";
      inputbar-fg = "${colorFg}";
      notification-bg = "${colorBg}";
      notification-fg = "${colorFg}";
      notification-error-bg = "${colorBg}";
      notification-error-fg = "${colorAccent4}";
      notification-warning-bg = "${colorBg}";
      notification-warning-fg = "${colorAccent4}";
      highlight-color = "${colorAccent2}";
      highlight-active-color = "${colorAccent3}";
      recolor-lightcolor = "${colorBg}";
      recolor-darkcolor = "${colorFg}";
      index-bg = "${colorBg}";
      index-fg = "${colorFg}";
      index-active-bg = "${colorAccent1}";
      index-active-fg = "${colorBg}";
    };
  };
}
