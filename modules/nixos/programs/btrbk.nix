{
  config,
  lib,
  ...
}: let
  cfg = config.my.programs.btrbk;

  commonSettings = {
    snapshot_preserve = "14d";
    snapshot_preserve_min = "3d";
    archive_preserve = "14d";
    archive_preserve_min = "3d";
  };
in {
  options.my.programs.btrbk = {
    enableHomeSnapshots = lib.mkEnableOption "snapshots for /home";
    enableSystemSnapshots = lib.mkEnableOption "snapshots for /";
  };

  config.services.btrbk.instances = {
    home = lib.mkIf cfg.enableHomeSnapshots {
      onCalendar = "hourly";
      settings =
        {
          volume."/" = {
            subvolume = "/home";
            snapshot_dir = "/.snapshots";
          };
        }
        // commonSettings;
    };
    system = lib.mkIf cfg.enableSystemSnapshots {
      onCalendar = "hourly";
      settings =
        {
          volume = {
            "/" = {
              subvolume = "/";
              snapshot_dir = "/.snapshots";
            };
            "/var" = {
              subvolume = "/var";
              snapshot_dir = "/.snapshots";
            };
          };
        }
        // commonSettings;
    };
  };
}
