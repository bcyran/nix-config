{
  my,
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

    programs = {
      chromium.enable = mkDefault true;
    };

    home.packages = with pkgs; [
      inter
      (nerdfonts.override {fonts = ["JetBrainsMono"];})
      libnotify
      wl-clipboard
      my.pkgs.backlight
      my.pkgs.wallpaper
      my.pkgs.scr
      my.pkgs.philipstv
      my.pkgs.philipstv-gui
      my.pkgs.timewall
    ];

    fonts.fontconfig = {
      enable = mkDefault true;
      defaultFonts = {
        sansSerif = mkDefault ["Inter"];
        monospace = mkDefault ["JetBrainsMonoNL NF"];
      };
    };
  };
}
