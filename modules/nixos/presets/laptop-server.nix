{
  config,
  lib,
  ...
}: let
  inherit (lib) mkDefault;
  cfg = config.my.presets.laptopServer;
in {
  options.my.presets.laptopServer.enable = lib.mkEnableOption "laptopServer";

  config = lib.mkIf cfg.enable {
    # Disable the screen after 2 minutes of inactivity
    boot.kernelParams = [
      "consoleblank=120"
    ];

    # Disable the lid switch completely
    services.logind.settings.Login = {
      HandleLidSwitch = mkDefault "ignore";
      HandleLidSwitchExternalPower = mkDefault "ignore";
      HandleLidSwitchDocked = mkDefault "ignore";
    };

    # Disable the suspend target completely
    systemd.targets.sleep.enable = mkDefault false;

    # Disable the screen backlight
    systemd.services.backlight = {
      description = "Disable the screen backlight";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "/bin/sh -c 'echo 0 > /sys/class/backlight/intel_backlight/brightness'";
      };
      wantedBy = ["multi-user.target"];
    };
  };
}
