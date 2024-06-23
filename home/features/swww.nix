{
  pkgs,
  lib,
  ...
}: let
  swww = pkgs.swww;
  swwwDaemonBin = "${swww}/bin/swww-daemon"; # `lib.getBin` doesn't work here
  wallpaperBin = lib.getExe pkgs.my.wallpaper;
in {
  home.packages = [swww];
  systemd.user.services.swww = {
    Unit = {
      Description = "Wallpaper daemon";
      PartOf = ["graphical-session.target"];
      After = ["graphical-session-pre.target"];
      StartLimitBurst = 15;
    };
    Service = {
      Type = "simple";
      ExecStart = swwwDaemonBin;
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };
  systemd.user.services.wallpaper = {
    Unit = {
      Description = "Wallpaper setter";
      PartOf = ["graphical-session.target"];
      After = ["swww.service"];
    };
    Service = {
      Type = "oneshot";
      ExecStart = wallpaperBin;
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };
}
