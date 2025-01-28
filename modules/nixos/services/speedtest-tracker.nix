{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.speedtest-tracker;

  speedtestTrackerVersion = "v1.2.0";
in {
  options = {
    my.services.speedtest-tracker = let
      serviceName = "Speedtest Tracker";
    in {
      enable = lib.mkEnableOption serviceName;
      address = my.lib.options.mkAddressOption serviceName;
      port = my.lib.options.mkPortOption serviceName 8082;
      openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
      domain = my.lib.options.mkDomainOption serviceName;
      environmentFiles = my.lib.options.mkEnvironmentFilesOption serviceName;
      dataDir = my.lib.options.mkDataDirOption serviceName "/var/lib/speedtest-tracker";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];

    virtualisation.oci-containers.containers.speedtest-tracker = {
      image = "lscr.io/linuxserver/speedtest-tracker:version-${speedtestTrackerVersion}";
      autoStart = true;
      ports = ["${cfg.address}:${builtins.toString cfg.port}:80"];
      volumes = [
        "${cfg.dataDir}:/config"
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
      inherit (cfg) environmentFiles;
    };

    users = rec {
      users.speedtest-tracker = {
        home = cfg.dataDir;
        createHome = true;
        group = "speedtest-tracker";
        uid = 2001;
        isSystemUser = true;
      };
      groups.speedtest-tracker.gid = users.speedtest-tracker.uid;
    };

    my.reverseProxy.virtualHosts.${cfg.domain} = lib.mkIf (cfg.domain != null) {
      backendAddress = "127.0.0.1";
      backendPort = cfg.port;
    };
  };
}
