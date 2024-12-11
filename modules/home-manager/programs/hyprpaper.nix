{
  my,
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.my.programs.hyprpaper;
  timewallCfg = config.my.programs.timewall;

  hyprpapersetScript = pkgs.writeShellApplication {
    name = "hyprpaperset";
    runtimeInputs = with pkgs; [gawk hyprland];
    text = ''
      if [[ $# -lt 1 ]]; then
          echo "Missing required argument PATH!" >&2
          echo "Usage: hyprpaperset PATH" >&2
          exit 1
      fi

      if [[ ! -f $1 ]]; then
          echo "File not found: $1" >&2
          exit 1
      fi

      mapfile -t monitors < <(hyprctl monitors | awk '/Monitor/ {print $2}')

      hyprctl hyprpaper preload "$1" > /dev/null

      for monitor in "''${monitors[@]}"; do
          hyprctl hyprpaper wallpaper "''${monitor},$1" > /dev/null
      done

      hyprctl hyprpaper unload unused > /dev/null
    '';
  };

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
      hyprpapersetScript
    ];

    systemd.user.services.wallpaper = lib.mkIf (!timewallCfg.enable) {
      Unit = {
        Description = "Wallpaper setter";
        PartOf = ["graphical-session.target"];
        After = ["hyprpaper.service"];
        Requires = ["hyprpaper.service"];
      };
      Service = {
        Type = "oneshot";
        ExecStartPre = "${sleepBin} 3";
        ExecStart = wallpaperBin;
      };
      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };
  };
}
