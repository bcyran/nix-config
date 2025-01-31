{
  config,
  lib,
  ...
}: let
  inherit (lib) mkDefault;
  cfg = config.my.presets.laptop;
in {
  options.my.presets.laptop.enable = lib.mkEnableOption "laptop";

  config = lib.mkIf cfg.enable {
    my.programs = {
      upower.enable = mkDefault true;
      kanata.enable = mkDefault true;
    };
    services = {
      tlp.enable = mkDefault true;
      logind = {
        lidSwitch = mkDefault "suspend";
        lidSwitchDocked = mkDefault "ignore";
        lidSwitchExternalPower = mkDefault "ignore";
      };
    };
  };
}
