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

      sessionVariables = {
        MY_WALLPAPERS_DIR = "${userCfg.home}/Obrazy/Tapety";
        MY_SCREENSHOTS_DIR = "${userCfg.home}/Obrazy/Zrzuty ekranu";
        MY_CONFIG_DIR = userCfg.configDir;
      };
    };
  };
}
