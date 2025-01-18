{
  inputs,
  config,
  lib,
  pkgs,
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
          target = "/mnt/backup/homelab";
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
      mkResticBackupFromBtrbkSnapshots = {
        host,
        tag,
        snapshotsGlob,
        time,
      }: {
        initialize = true;
        dynamicFilesFrom = ''
          find ${snapshotsGlob} -maxdepth 0 -type d | sort | tail -n 1
        '';
        extraBackupArgs = [
          "--host ${host}"
          "--tag ${tag}"
          "--group-by host,tags"
          "--retry-lock 2h"
        ];
        pruneOpts = [
          "--keep-daily 7"
        ];
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
        snapshotsGlob = "/mnt/backup/homelab/ROOT.*";
        time = "01:00";
      };
      homelab-var = mkResticBackupFromBtrbkSnapshots {
        host = "homelab";
        tag = "var";
        snapshotsGlob = "/mnt/backup/homelab/var.*";
        time = "02:00";
      };
      slimbook-home = mkResticBackupFromBtrbkSnapshots {
        host = "slimbook";
        tag = "home";
        snapshotsGlob = "/mnt/backup/slimbook/home.*";
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
      "restic-backups-homelab-root"
      "restic-backups-homelab-var"
      "restic-backups-slimbook-home"
    ];
    mkOnFailure = serviceName: {
      onFailure = ["ntfy-failed@${serviceName}.service"];
    };
  in
    lib.genAttrs notifyFailedServices mkOnFailure;
}
