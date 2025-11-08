{
  my,
  pkgs,
  inputs,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.grafana;
  grafanaDashboardsLib = inputs.grafana-dashboards.lib {inherit pkgs;};

  isNodeExporterActive =
    config.services.prometheus.enable
    && config.services.prometheus.exporters.node.enable;
in {
  options.my.services.grafana = let
    serviceName = "Grafana";
  in {
    enable = lib.mkEnableOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 3000;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];

    services.grafana = {
      enable = true;

      settings = {
        server = {
          http_addr = cfg.address;
          http_port = cfg.port;
          enforce_domain = false;
          enable_gzip = true;
          inherit (cfg.reverseProxy) domain;
        };
        analytics.reporting_enabled = false;
      };

      provision = {
        enable = true;

        datasources.settings.datasources = lib.mkIf config.services.prometheus.enable [
          {
            name = "Prometheus";
            type = "prometheus";
            url = "http://127.0.0.1:${toString config.services.prometheus.port}";
            default = true;
          }
        ];

        dashboards.settings.providers = lib.mkIf isNodeExporterActive [
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
