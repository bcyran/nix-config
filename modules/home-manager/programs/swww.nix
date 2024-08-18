{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (pkgs) swww;
  cfg = config.my.programs.swww;

  swwwDaemonBin = "${swww}/bin/swww-daemon"; # `lib.getBin` doesn't work here
  wallpaperBin = lib.getExe pkgs.my.wallpaper;
  sleepBin = "${pkgs.coreutils}/bin/sleep";
in {
  options.my.programs.swww.enable = lib.mkEnableOption "swww";

  config = lib.mkIf cfg.enable {
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
        Requires = ["swww.service"];
      };
      Service = {
        Type = "oneshot";
        ExecStartPre = "${sleepBin} 2";
        ExecStart = wallpaperBin;
      };
      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };
  };
}
