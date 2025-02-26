{
  my,
  inputs,
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.prometheus;

  grafanaDashboardsLib = inputs.grafana-dashboards.lib {inherit pkgs;};
in {
  options.my.services.prometheus = let
    serviceName = "Prometheus";
  in {
    enable = lib.mkEnableOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 9090;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];

    services = {
      prometheus = {
        enable = true;
        listenAddress = cfg.address;
        inherit (cfg) port;

        webExternalUrl = "https://${cfg.reverseProxy.domain}";

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
            disabledCollectors = [
              # This errors out on my system and I don't really care about it.
              "powersupplyclass"
            ];
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

    my.services.caddy.reverseProxyHosts = my.lib.caddy.mkReverseProxy cfg;
  };
}
