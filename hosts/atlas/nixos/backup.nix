{
  my,
  config,
  lib,
  pkgs,
  ...
}: let
  backupStore = my.lib.const.paths.atlas.backup;
in {
  sops.secrets = {
    restic_password_file = {};
    restic_env_file = {};
    restic_repository_name_file = {};
  };

  services = {
    sanoid = {
      enable = true;
      datasets = {
        "zroot/root" = {
          use_template = ["atlas"];
          recursive = false;
        };
        "zfast_store/fast_store/var_lib" = {
          use_template = ["atlas"];
          recursive = true;
        };
      };
      templates = {
        atlas = {
          hourly = 24;
          daily = 14;
          monthly = 0;
          yearly = 0;
          autosnap = true;
          autoprune = true;
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
          "--retry-lock 1h"
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
        snapshotsGlob = "/.zfs/snapshot/autosnap_*_hourly";
        time = "02:00";
      };
      atlas-var_lib = mkResticBackupFromBtrbkSnapshots {
        host = "atlas";
        tag = "var_lib";
        snapshotsGlob = "/var/lib/.zfs/snapshot/autosnap_*_hourly";
        time = "02:15";
      };
      atlas-var_lib_postgresql = mkResticBackupFromBtrbkSnapshots {
        host = "atlas";
        tag = "var_lib_postgresql";
        snapshotsGlob = "/var/lib/postgresql/.zfs/snapshot/autosnap_*_hourly";
        time = "02:45";
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
      "sanoid"
      "restic-backups-atlas-root"
      "restic-backups-atlas-var_lib"
      "restic-backups-atlas-var_lib_postgresql"
    ];
    mkOnFailure = serviceName: {
      onFailure = ["ntfy-failed@${serviceName}.service"];
    };
  in
    lib.genAttrs notifyFailedServices mkOnFailure;
}
