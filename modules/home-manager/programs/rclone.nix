{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.my.programs.rclone;
  cfgBisyncEnabled = builtins.length (builtins.attrNames cfg.bisyncPairs) > 0;

  rclonePackage = pkgs.rclone;
  rcloneBin = "${rclonePackage}/bin/rclone";
  rcloneOptions = [
    "-MvP"
    "--create-empty-src-dirs"
    "--compare size,modtime,checksum"
    "--filters-file %h/.config/rclone/filters.txt"
    "--conflict-resolve newer"
    "--conflict-loser delete"
    "--conflict-suffix sync-conflict-{DateOnly}-"
    "--suffix-keep-extension"
    "--resilient"
    "--recover"
    "--no-slow-hash"
    "--fix-case"
  ];
  rcloneOptionsStr = lib.concatStringsSep " " rcloneOptions;
in {
  options.my.programs.rclone = {
    enable = lib.mkEnableOption "rclone";

    bisyncPairs = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      example = {
        "/home/user/Dokumenty/" = "proton:/Dokumenty/";
      };
      description = ''
        A mapping of bidirectional synchronization pairs.
        Each key is a source directory and each value is a destination directory.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [rclonePackage];

    xdg.configFile."rclone/filters.txt" = {
      text = ''
        # Exclude all hidden files and folders
        - .*
        - .*/**

        # Exclude temp files
        - ~*.tmp
      '';
    };

    systemd.user = lib.mkIf cfgBisyncEnabled {
      services.rclone-bisync = {
        Unit = {
          Description = "Rclone bidirectional synchronization";
          Documentation = "man:rclone(1)";
          After = ["network-online.target"];
          Wants = ["network-online.target"];
          StartLimitIntervalSec = 60;
          StartLimitBurst = 1;
          X-SwitchMethod = "reload";
        };
        Service = {
          Type = "oneshot";
          ExecStart =
            lib.mapAttrsToList
            (src: dst: "${rcloneBin} bisync ${src} ${dst} ${rcloneOptionsStr}")
            cfg.bisyncPairs;
        };
      };

      timers.rclone-bisync = {
        Unit = {
          Description = "Rclone bidirectional synchronization schedule";
        };
        Timer = {
          OnCalendar = "*:0/30";
          Persistent = true;
          Unit = "rclone-bisync.service";
        };
        Install = {
          WantedBy = ["timers.target"];
        };
      };
    };
  };
}
