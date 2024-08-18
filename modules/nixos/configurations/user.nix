{
  config,
  lib,
  ...
}: let
  cfg = config.my.configurations.user;

  userCfg = config.my.user;
in {
  options.my.configurations.user.enable = lib.mkEnableOption "user";

  config = lib.mkIf cfg.enable {
    users = {
      users = {
        ${config.my.user.name} = {
          isNormalUser = true;
          description = userCfg.fullName;
          extraGroups = userCfg.groups;
          shell = userCfg.shell;
          uid = userCfg.uid;
        };
      };
      groups = {
        video = {};
      };
    };
  };
}
