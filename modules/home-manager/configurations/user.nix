{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.my.configurations.user;
  userCfg = config.my.user;
in {
  options.my.configurations.user.enable = mkEnableOption "user";

  config = mkIf cfg.enable {
    home = {
      username = userCfg.name;
      homeDirectory = userCfg.home;
    };
  };
}
