{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.my.programs.greetd;

  tuigreetBin = lib.getExe pkgs.tuigreet;
in {
  options.my.programs.greetd.enable = lib.mkEnableOption "greetd";

  config = lib.mkIf cfg.enable {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${tuigreetBin} --time --remember --remember-session --asterisks";
          user = "greeter";
        };
      };
    };
  };
}
