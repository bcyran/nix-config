{
  pkgs,
  config,
  lib,
  my,
  ...
}: let
  inherit (lib) mkDefault;
  cfg = config.my.presets.personal;
in {
  options.my.presets.personal.enable = lib.mkEnableOption "personal";

  config = lib.mkIf cfg.enable {
    my = {
      programs = {
        signal.enable = mkDefault true;
      };
    };

    programs = {
      yt-dlp.enable = mkDefault true;
      cava.enable = mkDefault true;
    };

    home.packages = with pkgs; [
      portfolio
      gnucash
      gimp
      libreoffice-fresh
      anydesk
      rustdesk
      calibre
      gthumb
      my.pkgs.ente-photos-desktop
      protonvpn-gui
      vlc
      tor-browser
      quickemu
      notesnook
      webcord
    ];
  };
}
