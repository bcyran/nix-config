{
  inputs,
  my,
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.my.programs.hyprpaper;
  timewallCfg = config.my.programs.timewall;

  timewallBin = lib.getExe inputs.timewall.packages.${pkgs.system}.timewall;
  wallpaperBin = lib.getExe my.pkgs.wallpaper;
  sleepBin = "${pkgs.coreutils}/bin/sleep";
in {
  options.my.programs.hyprpaper.enable = lib.mkEnableOption "hyprpaper";

  config = lib.mkIf cfg.enable {
    services.hyprpaper = {
      enable = true;
      settings = {
        ipc = "on";
      };
    };

    home.packages = [
      my.pkgs.hyprpaperset
    ];

    systemd.user.services.wallpaper = {
      Unit = {
        Description = "Wallpaper setter";
        PartOf = ["graphical-session.target"];
        After = ["hyprpaper.service"];
        Requires = ["hyprpaper.service"];
      };
      Service = {
        Type = "oneshot";
        ExecStartPre = "${sleepBin} 3";
        ExecStart =
          if timewallCfg.enable
          then "${timewallBin} set"
          else wallpaperBin;
      };
      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };
  };
}
