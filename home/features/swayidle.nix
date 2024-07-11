{
  pkgs,
  lib,
  ...
}: let
  backlightBin = lib.getExe pkgs.my.backlight;
  hyprctlBin = "${pkgs.hyprland}/bin/hyprctl";
  loginctlBin = "${pkgs.systemd}/bin/loginctl";
in {
  services.swayidle = {
    enable = true;
    extraArgs = ["-d"];
    timeouts = [
      {
        timeout = 5 * 60;
        command = "${backlightBin} set 10";
        resumeCommand = "${backlightBin} set 100";
      }
      {
        timeout = 15 * 60;
        command = "${hyprctlBin} dispatch dpms off";
        resumeCommand = "${hyprctlBin} dispatch dpms on";
      }
      {
        timeout = 30 * 60;
        command = "${loginctlBin} lock-session";
      }
    ];
  };
}
