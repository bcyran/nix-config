{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkDefault;
  cfg = config.my.presets.desktop;
in {
  options.my.presets.desktop.enable = lib.mkEnableOption "desktop";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      inter
      (nerdfonts.override {fonts = ["JetBrainsMono"];})
      libnotify
      wl-clipboard
      my.backlight
      my.wallpaper
      my.scr
      my.philipstv
      my.philipstv-gui
      my.timewall
    ];

    my = {
      programs = {
        alacritty.enable = mkDefault true;
        keepassxc.enable = mkDefault true;
        firefox.enable = mkDefault true;
        spotify.enable = mkDefault true;
        syncthing.enable = mkDefault true;
        megasync.enable = mkDefault true;
        udiskie.enable = mkDefault true;
        zathura.enable = mkDefault true;
      };
      configurations = {
        gtk.enable = mkDefault true;
        xdg.enable = mkDefault true;
        polkit.enable = mkDefault true;
      };
    };

    programs.chromium.enable = mkDefault true;

    fonts.fontconfig = {
      enable = mkDefault true;
      defaultFonts = {
        sansSerif = mkDefault ["Inter"];
        monospace = mkDefault ["JetBrainsMonoNL NF"];
      };
    };
  };
}
