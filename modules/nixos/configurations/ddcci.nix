{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.my.configurations.ddcci;
in {
  options.my.configurations.ddcci.enable = lib.mkEnableOption "ddcci";

  config = lib.mkIf cfg.enable {
    boot = {
      kernelModules = ["i2c-dev" "ddcci_backlight"];
      extraModulePackages = [config.boot.kernelPackages.ddcci-driver];
    };

    environment.systemPackages = [pkgs.ddcutil];
  };
}
