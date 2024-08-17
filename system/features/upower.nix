{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.my.programs.upower;
in {
  options.my.programs.upower.enable = mkEnableOption "upower";

  config = mkIf cfg.enable {
    services = {
      upower = {
        enable = true;
        percentageLow = 10;
        percentageCritical = 5;
      };
    };
  };
}
