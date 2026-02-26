{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (pkgs) spotify;
  cfg = config.my.programs.spotify;
in {
  options.my.programs.spotify.enable = lib.mkEnableOption "spotify";

  config = lib.mkIf cfg.enable {
    home.packages = [spotify];
    xdg.autostart.entries = [
      "${spotify}/share/applications/spotify.desktop"
    ];
  };
}
