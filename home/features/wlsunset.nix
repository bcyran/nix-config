{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.my.programs.wlsunset;
in {
  options.my.programs.wlsunset.enable = mkEnableOption "wlsunset";

  config = mkIf cfg.enable {
    services.wlsunset = {
      enable = true;
      latitude = "51.1";
      longitude = "17.0";
      temperature = {
        day = 6500;
        night = 4000;
      };
    };
  };
}
