{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.my.presets.personal;
in {
  options.my.presets.personal.enable = mkEnableOption "personal";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      portfolio
      gnucash
      obsidian
      gimp
      libreoffice-fresh
      anydesk
      calibre
      gthumb
      protonvpn-gui
      vlc
      tor-browser
      gnome.gnome-boxes
    ];

    my = {
      programs = {
        signal.enable = mkDefault true;
      };
    };
  };
}
