{
  my,
  config,
  lib,
  pkgs,
  ...
}: let
  backupStore = my.lib.const.paths.atlas.backup;
  replicasStore = my.lib.const.paths.atlas.replicas;
in {
  sops.secrets = {
    restic_password_file = {};
    restic_env_file = {};
    restic_repository_name_file = {};
  };

  services = {
    btrbk.instances = let
      snapshotRetention = "14d";
      snapshotRetentionMin = "1d";
      mkBtrbkInstance = {
        volume,
        subvolumes,
      }: {
        onCalendar = "hourly";
        settings = {
          volume.${volume} = {
            subvolume =
              my.lib.mapListToAttrs (subvolume: {
                name = subvolume;
                value = {};
              })
              subvolumes;
            snapshot_dir = ".snapshots";
            target = "${replicasStore}/atlas";
            target_preserve = snapshotRetention;
            target_preserve_min = snapshotRetentionMin;
          };
          snapshot_preserve = snapshotRetention;
          snapshot_preserve_min = snapshotRetentionMin;
          archive_preserve = snapshotRetention;
          archive_preserve_min = snapshotRetentionMin;
        };
      };
    in {
      root = mkBtrbkInstance {
        volume = "/";
        subvolumes = ["/"];
      };
      fast_store = mkBtrbkInstance {
        volume = "/mnt/fast_store";
        subvolumes = ["var_lib"];
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
      atlas-root = mkResticBackupFromBtrbkSnapshots {
        host = "atlas";
        tag = "root";
        snapshotsGlob = "/.snapshots/ROOT.*";
        time = "01:00";
      };
      atlas-var_lib = mkResticBackupFromBtrbkSnapshots {
        host = "atlas";
        tag = "var_lib";
        snapshotsGlob = "/mnt/fast_store/.snapshots/var_lib.*";
        time = "01:30";
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
      "btrbk-root"
      "btrbk-fast_store"
      "restic-backups-atlas-root"
      "restic-backups-atlas-var_lib"
      "restic-backups-slimbook-home"
    ];
    mkOnFailure = serviceName: {
      onFailure = ["ntfy-failed@${serviceName}.service"];
    };
  in
    lib.genAttrs notifyFailedServices mkOnFailure;
}
