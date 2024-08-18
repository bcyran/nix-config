{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.my.programs.syncthing;
in {
  options.my.programs.syncthing.enable = lib.mkEnableOption "syncthing";

  config = lib.mkIf cfg.enable {
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
