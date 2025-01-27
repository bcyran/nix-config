{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.programs.timewall;
in {
  options.my.programs.timewall.enable = lib.mkEnableOption "timewall";

  config = lib.mkIf cfg.enable {
    services.timewall = {
      enable = true;
      config = {
        setter.command = ["${lib.getExe my.pkgs.hyprpaperset}" "%f"];
        location = {
          lat = 51.11;
          lon = 17.02;
        };
      };
    };
  };
}
