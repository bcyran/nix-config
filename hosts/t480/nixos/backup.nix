{
  services.btrbk.instances.system = let
    snapshotRetention = "14d";
    snapshotRetentionMin = "1d";
  in {
    onCalendar = "hourly";
    settings = {
      volume."/" = {
        subvolume = {
          "/" = {};
          "/var" = {};
        };
        snapshot_dir = "/.snapshots";
        target = "/mnt/backup/t480";
        target_preserve = snapshotRetention;
        target_preserve_min = snapshotRetentionMin;
      };
      snapshot_preserve = snapshotRetention;
      snapshot_preserve_min = snapshotRetentionMin;
      archive_preserve = snapshotRetention;
      archive_preserve_min = snapshotRetentionMin;
    };
  };
}
