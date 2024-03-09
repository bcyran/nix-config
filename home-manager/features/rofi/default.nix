{ pkgs, ... }:
{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    plugins = with pkgs; [ rofi-calc ];
  };
  xdg.configFile.rofi = {
    source = ./files;
    recursive = true;
  };
}
