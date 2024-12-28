{
  inputs,
  pkgs,
  config,
  lib,
  ...
}: let
  grafanaDashboardsLib = inputs.grafana-dashboards.lib {inherit pkgs;};
  cfg = config.my.services.grafana;
in {
  options.my.services.grafana = {
    enable = lib.mkEnableOption "grafana";

    domain = lib.mkOption {
      type = lib.types.str;
      example = "grafana.home.my.tld";
      description = "The domain on which the Grafana server listens.";
    };

    port = lib.mkOption {
      type = lib.types.int;
      default = 3000;
      description = "The port on which the Grafana server listens.";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [cfg.port];

    services = {
      grafana = {
        enable = true;

        settings = {
          server = {
            http_addr = "127.0.0.1";
            http_port = cfg.port;
            enforce_domain = true;
            enable_gzip = true;
            inherit (cfg) domain;
          };
          analytics.reporting_enabled = false;
        };

        provision = {
          enable = true;

          datasources.settings.datasources = [
            {
              name = "Prometheus";
              type = "prometheus";
              url = "http://${config.services.prometheus.listenAddress}:${toString config.services.prometheus.port}";
              default = true;
            }
          ];

          dashboards.settings.providers = [
            (grafanaDashboardsLib.dashboardEntry {
              name = "node-exporter-full";
              path = grafanaDashboardsLib.fetchDashboard {
                name = "node-exporter-full";
                id = 1860;
                version = 37;
                hash = "sha256-PS9pNh3AqDpBMabZWjqsj1pgp7asuyGeJInP9Bdbpr0=";
              };
            })
          ];
        };
      };
    };

    my.services.reverseProxy.virtualHosts.${cfg.domain} = let
      inherit (config.services.grafana.settings.server) http_addr http_port;
    in {
      backendAddress = http_addr;
      backendPort = http_port;
    };
  };
}
