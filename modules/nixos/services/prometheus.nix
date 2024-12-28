{
  inputs,
  pkgs,
  config,
  lib,
  ...
}: let
  grafanaDashboardsLib = inputs.grafana-dashboards.lib {inherit pkgs;};
  cfg = config.my.services.prometheus;
in {
  options.my.services.prometheus = {
    enable = lib.mkEnableOption "prometheus";

    domain = lib.mkOption {
      type = lib.types.str;
      example = "prometheus.home.my.tld";
      description = "The domain on which the web UI is accessible.";
    };

    port = lib.mkOption {
      type = lib.types.int;
      default = 9090;
      description = "The port on which the prometheus server listens.";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = {
      allowedTCPPorts = [cfg.port];
    };

    services = {
      prometheus = {
        enable = true;
        listenAddress = "127.0.0.1";
        inherit (cfg) port;

        webExternalUrl = "https://${cfg.domain}";

        globalConfig = {
          scrape_interval = "15s";
          evaluation_interval = "15s";
        };

        exporters = {
          node = {
            enable = true;
            enabledCollectors = [
              "systemd"
              "processes"
            ];
            port = 9100;
          };
        };

        scrapeConfigs = [
          {
            job_name = "node";
            static_configs = [
              {
                targets = ["127.0.0.1:${toString config.services.prometheus.exporters.node.port}"];
              }
            ];
          }
        ];
      };

      grafana.provision = {
        enable = true;

        datasources.settings.datasources = lib.mkIf config.services.grafana.enable [
          {
            name = "Prometheus";
            type = "prometheus";
            url = "http://127.0.0.1:${toString cfg.port}";
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

    my.services.reverseProxy.virtualHosts.${cfg.domain} = let
      prometheusCfg = config.services.prometheus;
    in {
      backendAddress = prometheusCfg.listenAddress;
      backendPort = prometheusCfg.port;
    };
  };
}
