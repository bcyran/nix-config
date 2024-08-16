{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.my.presets.desktop;
in {
  options.my.presets.desktop.enable = mkEnableOption "desktop";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      roboto
      libnotify
      wl-clipboard
      (nerdfonts.override {fonts = ["JetBrainsMono"];})
      my.backlight
      my.wallpaper
      my.scr
      file-roller
      gnome-calculator
      gnome-font-viewer
      my.philipstv
      my.philipstv-gui
      my.timewall
    ];

    my = {
      programs = {
        alacritty.enable = true;
        hyprland.enable = true;
        waybar.enable = true;
        anyrun.enable = true;
        swaync.enable = true;
        hypridle.enable = true;
        hyprlock.enable = true;
        swww.enable = true;
        wlsunset.enable = true;
        keepassxc.enable = true;
        firefox.enable = true;
        spotify.enable = true;
        syncthing.enable = true;
        megasync.enable = true;
        udiskie.enable = true;
        zathura.enable = true;
      };
      configurations = {
        gtk.enable = true;
        xdg.enable = true;
        polkit.enable = true;
      };
    };

    programs.chromium.enable = true;
    services.poweralertd.enable = true;
  };
}