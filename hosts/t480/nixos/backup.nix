{
  inputs,
  config,
  ...
}: {
  sops = let
    homelabSopsFile = "${inputs.my-secrets}/homelab.yaml";
  in {
    secrets = {
      restic_password_file.sopsFile = homelabSopsFile;
      restic_env_file.sopsFile = homelabSopsFile;
      restic_repository_name_file.sopsFile = homelabSopsFile;
    };
  };

  services = {
    btrbk.instances.system = let
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

    restic.backups = let
      commonSettings = {
        initialize = true;
        passwordFile = config.sops.secrets.restic_password_file.path;
        environmentFile = config.sops.secrets.restic_env_file.path;
        repositoryFile = config.sops.secrets.restic_repository_name_file.path;
        createWrapper = true;
        pruneOpts = [
          "--keep-daily 7"
        ];
      };
    in {
      homelab-root =
        {
          dynamicFilesFrom = ''
            find /mnt/backup/t480/ROOT.* -maxdepth 0 -type d | sort | tail -n 1
          '';
          extraBackupArgs = [
            "--host homelab"
            "--tag root"
            "--group-by host,tags"
          ];
          timerConfig = {
            OnCalendar = "02:00";
            Persistent = true;
          };
        }
        // commonSettings;
      homelab-var =
        {
          dynamicFilesFrom = ''
            find /mnt/backup/t480/var.* -maxdepth 0 -type d | sort | tail -n 1
          '';
          extraBackupArgs = [
            "--host homelab"
            "--tag var"
            "--group-by host,tags"
          ];
          timerConfig = {
            OnCalendar = "02:15";
            Persistent = true;
          };
        }
        // commonSettings;
      slimbook-home =
        {
          dynamicFilesFrom = ''
            find /mnt/backup/slimbook/home.* -maxdepth 0 -type d | sort | tail -n 1
          '';
          extraBackupArgs = [
            "--host slimbook"
            "--tag home"
            "--group-by host,tags"
          ];
          timerConfig = {
            OnCalendar = "02:30";
            Persistent = true;
          };
        }
        // commonSettings;
    };
  };
}
