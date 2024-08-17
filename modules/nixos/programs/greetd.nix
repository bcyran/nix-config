{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.my.programs.greetd;

  tuigreetBin = lib.getExe pkgs.greetd.tuigreet;
in {
  options.my.programs.greetd.enable = mkEnableOption "greetd";

  config = mkIf cfg.enable {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${tuigreetBin} --time --cmd Hyprland --asterisks --remember";
          user = config.my.user.name;
        };
      };
    };
  };
}
