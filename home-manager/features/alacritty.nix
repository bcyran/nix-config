{
  programs.alacritty = {
    enable = true;
    settings = {
      colors = {
        bright = {
          black = "0x3e4452";
          blue = "0xa3b8ef";
          cyan = "0x56b6c2";
          green = "0x7eca9c";
          magenta = "0xde98fd";
          red = "0xbe5046";
          white = "0x5c6370";
          yellow = "0xd19a66";
        };
        normal = {
          black = "0x1e222a";
          blue = "0x61afef";
          cyan = "0x56b6c2";
          green = "0x98c379";
          magenta = "0xc678dd";
          red = "0xe06c75";
          white = "0xabb2bf";
          yellow = "0xe5c07b";
        };
        primary = {
          background = "0x1e222a";
          foreground = "0xabb2bf";
        };
      };
      env = {
        TERM = "xterm-256color";
        WINIT_X11_SCALE_FACTOR = "1";
      };
      font = {
        size = 10;
        normal.family = "JetBrainsMonoNL NF";
      };
      window.padding = {
        x = 5;
        y = 5;
      };
    };
  };
}
