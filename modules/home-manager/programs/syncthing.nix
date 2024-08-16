{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.my.programs.syncthing;
in {
  options.my.programs.syncthing.enable = mkEnableOption "syncthing";

  config = mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      tray = {
        enable = true;
        # For some reason syncthingtray-minimal always starts before the tray...
        package = pkgs.syncthingtray;
      };
    };
  };
}
