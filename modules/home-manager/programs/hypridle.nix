{
  my,
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.my.programs.hypridle;

  backlightBin = lib.getExe my.pkgs.backlight;
  hyprctlBin = "${pkgs.hyprland}/bin/hyprctl";
  loginctlBin = "${pkgs.systemd}/bin/loginctl";
  sleepBin = "${pkgs.coreutils}/bin/sleep";
in {
  options.my.programs.hypridle.enable = lib.mkEnableOption "hypridle";

  config = lib.mkIf cfg.enable {
    services.hypridle = {
      enable = true;
      settings = {
        listener = [
          {
            timeout = 5 * 60;
            on-timeout = "${backlightBin} save && ${backlightBin} set 10";
            on-resume = "${backlightBin} restore";
          }
          {
            timeout = 15 * 60;
            on-timeout = "${loginctlBin} lock-session";
          }
          {
            timeout = 20 * 60;
            on-timeout = "${hyprctlBin} dispatch dpms off";
            on-resume = "${hyprctlBin} dispatch dpms on && ${sleepBin} 7 && ${backlightBin} restore";
          }
        ];
      };
    };
  };
}
