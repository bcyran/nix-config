{pkgs, ...}: let
  bg_color = "#c8d3f5ff";
  ring_color = "#c8d3f5ff";
  ring_hl_color = "#1e2030dd";
  text_color = "#1e2030dd";
in {
  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-effects;
    settings = {
      screenshots = true;
      effect-blur = "5x2";
      font = "Roboto";
      font-size = 50;
      clock = true;
      timestr = "%H:%M:%S";
      datestr = "";
      indicator = true;
      indicator-idle-visible = true;

      text-color = text_color;
      inside-color = bg_color;
      inside-ver-color = bg_color;
      inside-wrong-color = bg_color;
      line-uses-inside = true;
      separator-color = bg_color;
      indicator-radius = 120;

      ring-color = ring_color;
      ring-ver-color = ring_color;
      ring-wrong-color = ring_color;
      key-hl-color = ring_hl_color;

      text-wrong-color = text_color;
      text-ver-color = text_color;
    };
  };
}
