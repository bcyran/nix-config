{config, ...}: {
  programs.alacritty = {
    enable = true;
    settings = {
      colors = {
        primary = {
          background = "#${config.colorScheme.palette.bg}";
          foreground = "#${config.colorScheme.palette.fg}";
        };
        normal = {
          black = "#${config.colorScheme.palette.base00}";
          red = "#${config.colorScheme.palette.base01}";
          green = "#${config.colorScheme.palette.base02}";
          yellow = "#${config.colorScheme.palette.base03}";
          blue = "#${config.colorScheme.palette.base04}";
          magenta = "#${config.colorScheme.palette.base05}";
          cyan = "#${config.colorScheme.palette.base06}";
          white = "#${config.colorScheme.palette.base07}";
        };
        bright = {
          black = "#${config.colorScheme.palette.base08}";
          red = "#${config.colorScheme.palette.base09}";
          green = "#${config.colorScheme.palette.base0A}";
          yellow = "#${config.colorScheme.palette.base0B}";
          blue = "#${config.colorScheme.palette.base0C}";
          magenta = "#${config.colorScheme.palette.base0D}";
          cyan = "#${config.colorScheme.palette.base0E}";
          white = "#${config.colorScheme.palette.base0F}";
        };
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
