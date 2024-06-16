{pkgs, ...}: let
  spotify = pkgs.spotify;
  spotifyDesktopName = "spotify.desktop";
  spotifyDesktop = "${spotify}/share/applications/${spotifyDesktopName}";
in {
  home.packages = [spotify];
  xdg.configFile."autostart/${spotifyDesktopName}" = {
    source = spotifyDesktop;
  };
}
