{
  config,
  lib,
  ...
}: let
  cfg = config.my.programs.nh;
in {
  options.my.programs.nh.enable = lib.mkEnableOption "nh";

  config = lib.mkIf cfg.enable {
    programs.nh = {
      enable = true;
      flake = config.my.user.dotfilesDir;
      clean = {
        enable = true;
        dates = "weekly";
        extraArgs = "--keep 5 --keep-since 7d";
      };
    };
  };
}
