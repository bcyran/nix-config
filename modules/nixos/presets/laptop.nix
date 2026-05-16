{
  config,
  lib,
  ...
}: let
  inherit (lib) mkDefault mkForce;
  cfg = config.my.presets.laptop;
in {
  options.my.presets.laptop.enable = lib.mkEnableOption "laptop";

  config = lib.mkIf cfg.enable {
    my.programs = {
      upower.enable = mkDefault true;
      kanata.enable = mkDefault true;
    };
    services = {
      tuned = {
        enable = mkDefault true;
        ppdSupport = mkDefault true;
      };
      tlp.enable = mkForce false;
      logind.settings.Login = {
        HandleLidSwitch = mkDefault "suspend";
        HandleLidSwitchDocked = mkDefault "ignore";
        HandleLidSwitchExternalPower = mkDefault "ignore";
      };
    };
  };
}
