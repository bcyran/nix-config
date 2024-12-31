{
  config,
  lib,
  ...
}: let
  cfg = config.my.services.speedtest-tracker;

  speedtestTrackerVersion = "v1.0.2";
  dataDir = "/var/lib/speedtest-tracker";
in {
  options = {
    my.services.speedtest-tracker = {
      enable = lib.mkEnableOption "Speedtest Tracker";

      port = lib.mkOption {
        type = lib.types.int;
        default = 8082;
        description = "The port on which the Speedtest Tracker is accessible.";
      };

      domain = lib.mkOption {
        type = lib.types.str;
        example = "speedtest-tracker.home.my.tld";
        description = "The domain on which the web UI is accessible.";
      };

      environmentFile = lib.mkOption {
        type = lib.types.str;
        example = "/path/to/env/file";
        description = "The path to the environment file.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [cfg.port];

    virtualisation.oci-containers.containers.speedtest-tracker = {
      image = "lscr.io/linuxserver/speedtest-tracker:version-${speedtestTrackerVersion}";
      autoStart = true;
      ports = ["127.0.0.1:${builtins.toString cfg.port}:80"];
      volumes = [
        "${dataDir}:/config"
      ];
      environment = {
        PUID = toString config.users.users.speedtest-tracker.uid;
        PGID = toString config.users.groups.speedtest-tracker.gid;
        DB_CONNECTION = "sqlite";
        DISPLAY_TIMEZONE = "Europe/Warsaw";
        DATETIME_FORMAT = "d.m.y H:i:s";
        CHART_DATETIME_FORMAT = "d.m H:i";
        SPEEDTEST_SCHEDULE = "0 * * * *";
        PUBLIC_DASHBOARD = "true";
      };
      environmentFiles = [cfg.environmentFile];
    };

    users = rec {
      users.speedtest-tracker = {
        home = dataDir;
        createHome = true;
        group = "speedtest-tracker";
        uid = 2001;
        isSystemUser = true;
      };
      groups.speedtest-tracker.gid = users.speedtest-tracker.uid;
    };

    my.services.reverseProxy.virtualHosts.${cfg.domain} = {
      backendAddress = "127.0.0.1";
      backendPort = cfg.port;
    };
  };
}
