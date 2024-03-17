{pkgs, ...}: let
  scripts = import ./scripts.nix {inherit pkgs;};
in {
  home.packages = with scripts; [
    backlight
    volume
    wallpaper
  ];
}
