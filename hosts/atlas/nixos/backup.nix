{
  my,
  config,
  lib,
  pkgs,
  ...
}: let
  replicasStore = my.lib.const.paths.atlas.replicas;
  resticCommonArgs = [
    "--group-by host,tags"
    "--retry-lock 2h"
  ];
  mkManageLatest = {
    host,
    tag,
    snapshotsGlob,
    latestSnapshotPath,
  }:
    pkgs.writeShellApplication {
      name = "restic-${host}-${tag}-latest";
      runtimeInputs = [
        pkgs.btrfs-progs
        pkgs.coreutils
        pkgs.findutils
      ];
      text = ''
        if [ "$1" = prepare ]; then
          snapshot="$(
            find ${snapshotsGlob} -maxdepth 0 -type d 2>/dev/null | sort | tail -n 1 || true
          )"
          if [ -z "$snapshot" ]; then
            echo "No snapshot found matching ${snapshotsGlob}" >&2
            exit 1
          fi
          if [ -e "${latestSnapshotPath}" ]; then
            btrfs subvolume delete "${latestSnapshotPath}"
          fi
          btrfs subvolume snapshot "$snapshot" "${latestSnapshotPath}"
        elif [ "$1" = cleanup ]; then
          if [ -e "${latestSnapshotPath}" ]; then
            btrfs subvolume delete "${latestSnapshotPath}"
          fi
        else
          echo "Usage: $0 prepare|cleanup" >&2
          exit 1
        fi
      '';
    };
  mkResticBackupFromBtrbkSnapshots = {
    host,
    tag,
    snapshotsGlob,
    time,
  }: let
    latestSnapshotPath = "${builtins.dirOf snapshotsGlob}/restic-${host}-${tag}-latest";
    manageLatest = mkManageLatest {
      inherit host tag snapshotsGlob latestSnapshotPath;
    };
  in {
    initialize = true;
    dynamicFilesFrom = "echo ${latestSnapshotPath}";
    backupPrepareCommand = "${lib.getExe manageLatest} prepare";
    backupCleanupCommand = "${lib.getExe manageLatest} cleanup";
    extraBackupArgs =
      [
        "--host ${host}"
        "--tag ${tag}"
      ]
      ++ resticCommonArgs;
    pruneOpts =
      [
        "--keep-daily 7"
      ]
      ++ resticCommonArgs;
    timerConfig = {
      OnCalendar = time;
      Persistent = true;
    };
    passwordFile = config.sops.secrets.restic_password_file.path;
    environmentFile = config.sops.secrets.restic_env_file.path;
    repositoryFile = config.sops.secrets.restic_repository_name_file.path;
  };
in {
  sops.secrets = {
    restic_password_file = {};
    restic_env_file = {};
    restic_repository_name_file = {};
  };

  services = {
    btrbk = {
      instances = let
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
      sshAccess = [
        {
          key = my.lib.const.sshKeys.btrbkAtSlimbook;
          roles = ["info" "source" "target" "delete"];
        }
      ];
    };

    restic.backups = {
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
        snapshotsGlob = "${replicasStore}/slimbook/home.*";
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
