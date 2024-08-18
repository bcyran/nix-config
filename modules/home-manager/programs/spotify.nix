{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (pkgs) spotify;
  cfg = config.my.programs.spotify;

  spotifyDesktopName = "spotify.desktop";
  spotifyDesktop = "${spotify}/share/applications/${spotifyDesktopName}";
in {
  options.my.programs.spotify.enable = lib.mkEnableOption "spotify";

  config = lib.mkIf cfg.enable {
    home.packages = [spotify];
    xdg.configFile."autostart/${spotifyDesktopName}" = {
      source = spotifyDesktop;
    };
  };
}
