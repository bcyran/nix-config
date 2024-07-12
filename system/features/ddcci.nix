{config, ...}: {
  boot.kernelModules = ["i2c-dev" "ddcci_backlight"];
  boot.extraModulePackages = [config.boot.kernelPackages.ddcci-driver];
}
