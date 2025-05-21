{
  inputs,
  pkgs,
  config,
  lib,
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
        joplin-desktop.enable = mkDefault true;
        portfolio-performance.enable = mkDefault true;
        libreoffice.enable = mkDefault true;
      };
    };

    programs = {
      yt-dlp.enable = mkDefault true;
      cava.enable = mkDefault true;
    };

    services.nextcloud-client = {
      enable = true;
      startInBackground = true;
    };

    home.packages = with pkgs; [
      gnucash
      gimp3
      rustdesk-flutter
      calibre
      gthumb
      vlc
      tor-browser
      webcord
      jellyfin-media-player
      feishin
      inputs.zen-browser.packages."${pkgs.system}".default
    ];
  };
}
