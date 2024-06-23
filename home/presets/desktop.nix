{
  pkgs,
  config,
  lib,
  ...
}: let
  rofi = import ../features/rofi {inherit pkgs config lib;};
in {
  imports = [
    ../features/alacritty.nix
    ../features/hyprland
    ../features/dunst.nix
    ../features/swayidle.nix
    ../features/wlsunset.nix
    ../features/swaylock.nix
    ../features/zathura.nix
    ../features/keepassxc.nix
    ../features/spotify.nix
    ../features/megasync.nix
    ../features/syncthing.nix
    ../features/swww.nix
    ../features/gtk.nix
    ../features/waybar
    ../features/onagre
  ];

  home.packages = with pkgs; [
    roboto
    libnotify
    (nerdfonts.override {fonts = ["JetBrainsMono"];})
    my.backlight
    my.wallpaper
    my.scr
    rofi.appmenu
    rofi.powermenu
    rofi.calc
    rofi.runmenu
    gparted
    gnome.file-roller
    gnome.gnome-calculator
    gnome.gnome-font-viewer
  ];

  programs.firefox.enable = true;
  programs.chromium.enable = true;
}
