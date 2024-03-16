{
  programs.alacritty = {
    enable = true;
    settings = {
      colors = {
        primary = {
          background = "#222436";
          foreground = "#c8d3f5";
        };
        normal = {
          black = "#1b1d2b";
          red = "#ff757f";
          green = "#c3e88d";
          yellow = "#ffc777";
          blue = "#82aaff";
          magenta = "#c099ff";
          cyan = "#86e1fc";
          white = "#828bb8";
        };
        bright = {
          black = "#444a73";
          red = "#ff757f";
          green = "#c3e88d";
          yellow = "#ffc777";
          blue = "#82aaff";
          magenta = "#c099ff";
          cyan = "#86e1fc";
          white = "#c8d3f5";
        };
        indexed_colors = [
          { index = 16; color = "#ff966c"; }
          { index = 17; color = "#c53b53"; }
        ];
      };
      env = {
        TERM = "xterm-256color";
        WINIT_X11_SCALE_FACTOR = "1";
      };
      font = {
        size = 14;
        normal.family = "JetBrainsMonoNL NF";
      };
      window.padding = {
        x = 5;
        y = 5;
      };
    };
  };
}
