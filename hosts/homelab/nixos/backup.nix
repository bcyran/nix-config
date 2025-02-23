{
  my,
  config,
  lib,
  pkgs,
  ...
}: let
  backupStore = my.lib.const.paths.homelab.backup;
in {
  sops.secrets = {
    restic_password_file = {};
    restic_env_file = {};
    restic_repository_name_file = {};
  };

  services = let
    snapshotRetention = "14d";
    snapshotRetentionMin = "1d";
  in {
    btrbk.instances = {
      system = {
        onCalendar = "hourly";
        settings = {
          volume."/" = {
            subvolume = {
              "/" = {};
            };
            snapshot_dir = "/.snapshots";
            target = "${backupStore}/homelab";
            target_preserve = snapshotRetention;
            target_preserve_min = snapshotRetentionMin;
          };
          snapshot_preserve = snapshotRetention;
          snapshot_preserve_min = snapshotRetentionMin;
          archive_preserve = snapshotRetention;
          archive_preserve_min = snapshotRetentionMin;
        };
      };
      fast_store = {
        onCalendar = "hourly";
        settings = {
          volume."/mnt/fast_store" = {
            subvolume = {
              "var_lib" = {};
            };
            snapshot_dir = ".snapshots";
            target = "${backupStore}/homelab";
            target_preserve = snapshotRetention;
            target_preserve_min = snapshotRetentionMin;
          };
          snapshot_preserve = snapshotRetention;
          snapshot_preserve_min = snapshotRetentionMin;
          archive_preserve = snapshotRetention;
          archive_preserve_min = snapshotRetentionMin;
        };
      };
    };

    restic.backups = let
      mkResticBackupFromBtrbkSnapshots = {
        host,
        tag,
        snapshotsGlob,
        time,
      }: let
        commonArgs = [
          "--group-by host,tags"
          "--retry-lock 2h"
        ];
      in {
        initialize = true;
        dynamicFilesFrom = ''
          find ${snapshotsGlob} -maxdepth 0 -type d | sort | tail -n 1
        '';
        extraBackupArgs =
          [
            "--host ${host}"
            "--tag ${tag}"
          ]
          ++ commonArgs;
        pruneOpts =
          [
            "--keep-daily 7"
          ]
          ++ commonArgs;
        timerConfig = {
          OnCalendar = time;
          Persistent = true;
        };
        passwordFile = config.sops.secrets.restic_password_file.path;
        environmentFile = config.sops.secrets.restic_env_file.path;
        repositoryFile = config.sops.secrets.restic_repository_name_file.path;
      };
    in {
      homelab-root = mkResticBackupFromBtrbkSnapshots {
        host = "homelab";
        tag = "root";
        snapshotsGlob = "${backupStore}/homelab/ROOT.*";
        time = "01:00";
      };
      homelab-var_lib = mkResticBackupFromBtrbkSnapshots {
        host = "homelab";
        tag = "var_lib";
        snapshotsGlob = "${backupStore}/homelab/var_lib.*";
        time = "02:00";
      };
      slimbook-home = mkResticBackupFromBtrbkSnapshots {
        host = "slimbook";
        tag = "home";
        snapshotsGlob = "${backupStore}/slimbook/home.*";
        time = "03:00";
      };
    };
  };

  # Our own simple restic wrapper with B2 config.
  environment.systemPackages = [
    (pkgs.writeShellApplication {
      name = "restic-b2";
      text = ''
        set -a # automatically export variables

        # shellcheck disable=SC1091
        source ${config.sops.secrets.restic_env_file.path}
        export RESTIC_PASSWORD_FILE=${config.sops.secrets.restic_password_file.path}
        export RESTIC_REPOSITORY_FILE=${config.sops.secrets.restic_repository_name_file.path}

        exec ${pkgs.restic}/bin/restic "$@"
      '';
    })
  ];

  systemd.services = let
    notifyFailedServices = [
      "btrbk-system"
      "btrbk-fast_store"
      "restic-backups-homelab-root"
      "restic-backups-homelab-var_lib"
      "restic-backups-slimbook-home"
    ];
    mkOnFailure = serviceName: {
      onFailure = ["ntfy-failed@${serviceName}.service"];
    };
  in
    lib.genAttrs notifyFailedServices mkOnFailure;
}
