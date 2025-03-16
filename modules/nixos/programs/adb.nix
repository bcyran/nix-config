{
  config,
  lib,
  ...
}: let
  cfg = config.my.programs.adb;
in {
  options.my.programs.adb.enable = lib.mkEnableOption "adb";

  config = lib.mkIf cfg.enable {
    programs.adb.enable = true;
    users.users.${config.my.user.name}.extraGroups = ["adbusers"];
  };
}
