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
      stable.portfolio # XXX: The package in unstable is broken
      gnucash
      gimp
      libreoffice-fresh
      rustdesk
      calibre
      gthumb
      protonvpn-gui
      vlc
      tor-browser
      quickemu
      webcord
      jellyfin-media-player
      inputs.zen-browser.packages."${pkgs.system}".default
    ];
  };
}
