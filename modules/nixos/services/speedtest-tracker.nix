{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.speedtest-tracker;

  speedtestTrackerVersion = "v1.5.0";
  dataDir = "/var/lib/speedtest-tracker";
in {
  options = {
    my.services.speedtest-tracker = let
      serviceName = "Speedtest Tracker";
    in {
      enable = lib.mkEnableOption serviceName;
      address = my.lib.options.mkAddressOption serviceName;
      port = my.lib.options.mkPortOption serviceName 8082;
      openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
      reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;
      environmentFiles = my.lib.options.mkEnvironmentFilesOption serviceName;
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];

    virtualisation.oci-containers.containers.speedtest-tracker = {
      image = "lscr.io/linuxserver/speedtest-tracker:version-${speedtestTrackerVersion}";
      autoStart = true;
      ports = ["${cfg.address}:${builtins.toString cfg.port}:80"];
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
      inherit (cfg) environmentFiles;
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

    my.services.caddy.reverseProxyHosts = my.lib.caddy.mkReverseProxy cfg;
  };
}
