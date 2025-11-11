{
  config,
  lib,
  ...
}: let
  inherit (lib) mkDefault;
  cfg = config.my.presets.cosmic;
in {
  options.my.presets.cosmic.enable = lib.mkEnableOption "cosmic";

  config = lib.mkIf cfg.enable {
    services = {
      desktopManager.cosmic.enable = mkDefault true;
      displayManager.cosmic-greeter.enable = mkDefault true;
    };
  };
}
