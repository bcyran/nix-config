{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.my.configurations.fileManagement;
in {
  options.my.configurations.fileManagement.enable = lib.mkEnableOption "file management";

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
    };

    environment.systemPackages = [pkgs.file-roller];

    boot.supportedFilesystems = ["ntfs" "exfat"];
  };
}
