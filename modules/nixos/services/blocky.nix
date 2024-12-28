{
  inputs,
  pkgs,
  config,
  lib,
  ...
}: let
  grafanaDashboardsLib = inputs.grafana-dashboards.lib {inherit pkgs;};
  cfg = config.my.services.blocky;

  blockyUrl = "127.0.0.1:${toString cfg.httpPort}";
  blockyPrometheusJobName = "blocky";
in {
  options.my.services.blocky = {
    enable = lib.mkEnableOption "blocky";

    customDNSMappings = lib.mkOption {
      type = with lib.types; attrsOf str;
      default = {};
      description = "Custom DNS mappings.";
    };

    dnsPort = lib.mkOption {
      type = lib.types.int;
      default = 53;
      description = "The port on which the DNS server listens.";
    };
    httpPort = lib.mkOption {
      type = lib.types.int;
      default = 4000;
      description = "The port on which the HTTP server listens.";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = {
      allowedTCPPorts = [cfg.dnsPort];
      allowedUDPPorts = [cfg.dnsPort];
    };

    services = {
      blocky = {
        enable = true;
        settings = {
          ports = {
            dns = cfg.dnsPort;
            http = cfg.httpPort;
          };
          upstreams.groups.default = [
            "https://cloudflare-dns.com/dns-query"
          ];
          bootstrapDns = {
            upstream = "https://cloudflare-dns.com/dns-query";
            ips = ["1.1.1.1" "1.0.0.1"];
          };
          blocking = {
            denylists = {
              ads = [
                "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
              ];
            };
            clientGroupsBlock = {
              default = ["ads"];
            };
          };
          caching = {
            minTime = "5m";
            maxTime = "30m";
            prefetching = true;
          };
          customDNS.mapping = cfg.customDNSMappings;
          prometheus.enable = true;
        };
      };

      prometheus.scrapeConfigs = lib.mkIf config.services.prometheus.enable [
        {
          job_name = blockyPrometheusJobName;
          static_configs = [
            {
              targets = [blockyUrl];
            }
          ];
        }
      ];

      grafana = lib.mkIf config.services.grafana.enable {
        settings.panels.disable_sanitize_html = true;

        provision.dashboards.settings.providers = [
          (grafanaDashboardsLib.dashboardEntry {
            name = "blocky";
            path = grafanaDashboardsLib.fetchDashboard {
              name = "blocky";
              id = 13768;
              version = 4;
              hash = "sha256-61Rapsit6gpG8GtnNpO3jckZwfDkzZtFFaFMVStAf6U=";
            };
            transformations = grafanaDashboardsLib.fillTemplating [
              {
                key = "DS_PROMETHEUS";
                value = "Prometheus";
              }
              {
                key = "job";
                value = blockyPrometheusJobName;
              }
              {
                key = "blocky_url";
                value = "";
              }
            ];
          })
        ];
      };
    };
  };
}
