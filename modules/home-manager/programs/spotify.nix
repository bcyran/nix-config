{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.my.programs.spotify;

  spotify = pkgs.spotify;
  spotifyDesktopName = "spotify.desktop";
  spotifyDesktop = "${spotify}/share/applications/${spotifyDesktopName}";
in {
  options.my.programs.spotify.enable = mkEnableOption "spotify";

  config = mkIf cfg.enable {
    home.packages = [spotify];
    xdg.configFile."autostart/${spotifyDesktopName}" = {
      source = spotifyDesktop;
    };
  };
}
