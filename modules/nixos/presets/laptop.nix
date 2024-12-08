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
      tlp.enable = mkDefault true;
      upower.enable = mkDefault true;
      kanata.enable = mkDefault true;
    };
    services.logind.lidSwitchExternalPower = mkDefault "ignore";
  };
}
