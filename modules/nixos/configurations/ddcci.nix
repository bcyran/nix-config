{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.my.configurations.ddcci;

  ddcutilBin = "${pkgs.ddcutil}/bin/ddcutil";
  sleepBin = "${pkgs.coreutils}/bin/sleep";
in {
  options.my.configurations.ddcci.enable = lib.mkEnableOption "ddcci";

  config = lib.mkIf cfg.enable {
    boot = {
      kernelModules = ["i2c-dev" "ddcci_backlight"];
      extraModulePackages = [config.boot.kernelPackages.ddcci-driver];
    };

    environment.systemPackages = [pkgs.ddcutil];

    # Source: https://discourse.nixos.org/t/brightness-control-of-external-monitors-with-ddcci-backlight/8639/15
    services.udev.extraRules = ''
      SUBSYSTEM=="i2c-dev", ACTION=="add",\
        TAG+="ddcci",\
        TAG+="systemd",\
        ENV{SYSTEMD_WANTS}+="ddcci@$kernel.service"
    '';

    systemd.services."ddcci@" = {
      description = "Force DDC/CI device detection";
      scriptArgs = "%i";
      script = ''
        echo "Trying to force DDC/CI device detection for $1."
        id=$(echo "$1" | cut -d "-" -f 2)
        for i in {1..5}; do
          echo "Attempt $i..."
          if ${ddcutilBin} getvcp 10 -b "$id"; then
            echo 'ddcci 0x37' > "/sys/bus/i2c/devices/$1/new_device"
            echo 'Success!'
            break
          fi
          sleep 1
        done
      '';
      serviceConfig = {
        Type = "oneshot";
        ExecStartPre = "${sleepBin} 3";
      };
    };
  };
}
