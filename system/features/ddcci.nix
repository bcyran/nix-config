{
  config,
  pkgs,
  ...
}: {
  boot.kernelModules = ["i2c-dev" "ddcci_backlight"];
  boot.extraModulePackages = [config.boot.kernelPackages.ddcci-driver];
  environment.systemPackages = with pkgs; [
    ddcutil
  ];
}
