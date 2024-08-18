{
  config,
  lib,
  ...
}: let
  cfg = config.my.programs.upower;
in {
  options.my.programs.upower.enable = lib.mkEnableOption "upower";

  config = lib.mkIf cfg.enable {
    services = {
      upower = {
        enable = true;
        percentageLow = 10;
        percentageCritical = 5;
      };
    };
  };
}
