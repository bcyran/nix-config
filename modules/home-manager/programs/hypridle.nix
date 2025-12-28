{
  my,
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.my.programs.hypridle;
  programsCfg = config.my.programs;

  pidofBin = "${pkgs.procps}/bin/pidof";
  pkillBin = "${pkgs.procps}/bin/pkill";
  backlightBin = lib.getExe my.pkgs.backlight;
  hyprctlBin = "${pkgs.hyprland}/bin/hyprctl";
  loginctlBin = "${pkgs.systemd}/bin/loginctl";
  sleepBin = "${pkgs.coreutils}/bin/sleep";

  swaylockBin = lib.getExe pkgs.swaylock;
  hyprlockBin = lib.getExe pkgs.hyprlock;

  lockerName =
    if programsCfg.hyprlock.enable
    then "hyprlock"
    else "swaylock";
  lockerBin =
    if programsCfg.hyprlock.enable
    then hyprlockBin
    else swaylockBin;
in {
  options.my.programs.hypridle.enable = lib.mkEnableOption "hypridle";

  config = lib.mkIf cfg.enable {
    services.hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "${pidofBin} ${lockerName} || ${lockerBin}";
          unlock_cmd = "${pkillBin} -USR1 ${lockerName}";
          before_sleep_cmd = "${loginctlBin} lock-session";
        };
        listener = [
          {
            timeout = 5 * 60;
            on-timeout = "${backlightBin} save && ${backlightBin} set 10";
            on-resume = "${backlightBin} restore";
          }
          {
            timeout = 10 * 60;
            on-timeout = "${hyprctlBin} dispatch dpms off";
            on-resume = "${hyprctlBin} dispatch dpms on && ${sleepBin} 5 && ${backlightBin} restore";
          }
          {
            timeout = 30 * 60;
            on-timeout = "${loginctlBin} lock-session";
          }
        ];
      };
    };
  };
}
