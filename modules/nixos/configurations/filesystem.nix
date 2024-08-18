{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.my.configurations.filesystem;
in {
  options.my.configurations.filesystem.enable = lib.mkEnableOption "filesystem";

  config = lib.mkIf cfg.enable {
    services = {
      udisks2.enable = true;
      gvfs.enable = true;
      tumbler.enable = true;
    };
    programs = {
      thunar = {
        enable = true;
        plugins = with pkgs.xfce; [thunar-volman thunar-archive-plugin];
      };
      xfconf.enable = true;
      file-roller.enable = true;
    };
  };
}
