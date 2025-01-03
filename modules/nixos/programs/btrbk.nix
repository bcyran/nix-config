{
  config,
  lib,
  ...
}: let
  cfg = config.my.programs.btrbk;

  homeRetention = "14d";
  homeRetentionMin = "3d";
  systemRetention = "14d";
  systemRetentionMin = "1d";
in {
  options.my.programs.btrbk = {
    enableHomeSnapshots = lib.mkEnableOption "snapshots for /home";
    homeBackupTarget = lib.mkOption {
      type = with lib.types; nullOr path;
      default = null;
      example = "/mnt/backup/home";
      description = "The target for home backups";
    };

    enableSystemSnapshots = lib.mkEnableOption "snapshots for /";
    systemBackupTarget = lib.mkOption {
      type = with lib.types; nullOr path;
      default = null;
      example = "/mnt/backup/system";
      description = "The target for system backups";
    };
  };

  config.services.btrbk.instances = {
    home = lib.mkIf cfg.enableHomeSnapshots {
      onCalendar = "hourly";
      settings = {
        volume."/" =
          {
            subvolume = "/home";
            snapshot_dir = "/.snapshots";
          }
          // lib.optionalAttrs (cfg.homeBackupTarget != null) {
            target = cfg.homeBackupTarget;
            target_preserve = homeRetention;
            target_preserve_min = homeRetentionMin;
          };
        snapshot_preserve = homeRetention;
        snapshot_preserve_min = homeRetentionMin;
        archive_preserve = homeRetention;
        archive_preserve_min = homeRetentionMin;
      };
    };
    system = lib.mkIf cfg.enableSystemSnapshots {
      onCalendar = "hourly";
      settings = {
        volume."/" =
          {
            subvolume = {
              "/" = {};
              "/var" = {};
            };
            snapshot_dir = "/.snapshots";
          }
          // lib.optionalAttrs (cfg.systemBackupTarget != null) {
            target = cfg.systemBackupTarget;
            target_preserve = systemRetention;
            target_preserve_min = systemRetentionMin;
          };
        snapshot_preserve = systemRetention;
        snapshot_preserve_min = systemRetentionMin;
        archive_preserve = systemRetention;
        archive_preserve_min = systemRetentionMin;
      };
    };
  };
}
