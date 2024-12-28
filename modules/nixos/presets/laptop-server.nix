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
    services.logind = {
      lidSwitch = mkDefault "ignore";
      lidSwitchExternalPower = mkDefault "ignore";
      lidSwitchDocked = mkDefault "ignore";
    };

    # Disable the suspend target completely
    systemd.targets.sleep.enable = mkDefault false;
  };
}
