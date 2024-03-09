{ pkgs, ... }:
{
  programs.waybar.enable = true;
  xdg.configFile.waybar = {
    source = ./files;
    recursive = true;
  };
  home.packages = with pkgs; [ icomoon-feather ];
}
