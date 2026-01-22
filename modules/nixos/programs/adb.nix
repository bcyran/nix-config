{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.programs.adb;
in {
  options.my.programs.adb.enable = lib.mkEnableOption "adb";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [pkgs.android-tools];
    users.users.${config.my.user.name}.extraGroups = ["adbusers"];
  };
}
