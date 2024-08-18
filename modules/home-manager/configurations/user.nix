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
    home = {
      username = userCfg.name;
      homeDirectory = userCfg.home;
    };
  };
}
