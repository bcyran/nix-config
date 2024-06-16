{
  pkgs,
  config,
  ...
}: let
  rofi = import ../features/rofi {inherit pkgs config;};
in {
  imports = [
    ../features/alacritty.nix
    ../features/hyprland.nix
    ../features/dunst.nix
    ../features/swayidle.nix
    ../features/wlsunset.nix
    ../features/swaylock.nix
    ../features/zathura.nix
    ../features/keepassxc.nix
    ../features/spotify.nix
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
    xfce.thunar
    rofi.appmenu
    rofi.powermenu
    rofi.calc
    rofi.runmenu
  ];

  programs.firefox.enable = true;
}
