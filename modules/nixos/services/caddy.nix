{
  inputs,
  pkgs,
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.caddy;
  lokiCfg = config.my.services.loki;

  grafanaDashboardsLib = inputs.grafana-dashboards.lib {inherit pkgs;};
  caddyWithOvhDnsPlugin = pkgs.caddy.withPlugins {
    plugins = ["github.com/caddy-dns/ovh@v0.0.3"];
    hash = "sha256-MOdzcf083FbL3Va3bISFhx4ylz9Pu7tiT6wpopOY89w";
  };
in {
  options.my.services.caddy = let
    serviceName = "Caddy web server";
  in {
    enable = lib.mkEnableOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    httpPort = my.lib.options.mkPortOption serviceName 80;
    httpsPort = my.lib.options.mkPortOption serviceName 443;
    adminAddress = my.lib.options.mkAddressOption serviceName;
    adminPort = my.lib.options.mkPortOption serviceName 2019;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    environmentFile = my.lib.options.mkEnvironmentFileOption serviceName;

    extraConfig = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Extra configuration to add to the Caddyfile.";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [cfg.httpPort cfg.httpsPort];
    };

    services = {
      caddy = {
        enable = true;
        package = caddyWithOvhDnsPlugin;
        inherit (cfg) environmentFile extraConfig;

        globalConfig = ''
          default_bind ${toString cfg.address}
          http_port ${toString cfg.httpPort}
          https_port ${toString cfg.httpsPort}
          admin ${cfg.adminAddress}:${toString cfg.adminPort}

          metrics
        '';
      };

      promtail.configuration.scrape_configs = lib.mkIf lokiCfg.enable [
        {
          job_name = "caddy";
          static_configs = [
            {
              targets = ["localhost"];
              labels = {
                job = "caddy-access";
                agent = "caddy-promtail";
                __path__ = "/var/log/caddy/*.log";
              };
            }
          ];
          pipeline_stages = [
            {
              json = {
                expressions = {
                  timestamp = "ts";
                };
              };
            }
            {
              timestamp = {
                source = "timestamp";
                format = "Unix";
              };
            }
          ];
        }
      ];

      prometheus.scrapeConfigs = lib.mkIf config.services.prometheus.enable [
        {
          job_name = "caddy";
          static_configs = [
            {
              targets = ["127.0.0.1:${toString cfg.adminPort}"];
            }
          ];
        }
      ];

      grafana = lib.mkIf config.services.grafana.enable {
        settings.panels.disable_sanitize_html = true;

        provision.dashboards.settings.providers = [
          (grafanaDashboardsLib.dashboardEntry {
            name = "caddy";
            path = grafanaDashboardsLib.fetchDashboard {
              name = "caddy";
              id = 20802;
              version = 1;
              hash = "sha256-36tLF4VJJLs6SkTp9RJI84EsixgKYarOH2AOGNArK3E=";
            };
            transformations = grafanaDashboardsLib.fillTemplating [
              {
                key = "DS_PROMETHEUS-INDUMIA";
                value = "Prometheus";
              }
              {
                key = "DS_LOKI-INDUMIA";
                value = "Loki";
              }
            ];
          })
        ];
      };
    };
  };
}
