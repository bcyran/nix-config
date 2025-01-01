{
  inputs,
  pkgs,
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.caddy;
  reverseProxyCfg = config.my.services.reverseProxy;
  lokiCfg = config.my.services.loki;

  grafanaDashboardsLib = inputs.grafana-dashboards.lib {inherit pkgs;};
  caddyWithOvhDnsPlugin = my.pkgs.caddy.withPlugins {
    plugins = ["github.com/caddy-dns/ovh@v0.0.3"];
    hash = "sha256-Sy9ZV/rmnfi1aaDfZo8B7dD3JoEMb9onc9swpjQfJNc=";
  };

  makeVirtualHost = domain: vhost: {
    ${domain}.extraConfig = ''
      reverse_proxy ${vhost.backendAddress}:${toString vhost.backendPort}

      log {
        output file /var/log/caddy/access-${domain}.log {
          roll_size 100MiB
          roll_keep 5
          roll_keep_for 2160h
          mode 644
        }
      }

      tls {
        dns ovh {
          endpoint {$OVH_ENDPOINT}
          application_key {$OVH_APPLICATION_KEY}
          application_secret {$OVH_APPLICATION_SECRET}
          consumer_key {$OVH_CONSUMER_KEY}
        }
      }
    '';
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
    environmentFiles = my.lib.options.mkEnvironmentFilesOption serviceName;
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [cfg.httpPort cfg.httpsPort];
    };

    services = {
      caddy = {
        enable = true;
        package = caddyWithOvhDnsPlugin;

        globalConfig = ''
          default_bind ${toString cfg.address}
          http_port ${toString cfg.httpPort}
          https_port ${toString cfg.httpsPort}
          admin ${cfg.adminAddress}:${toString cfg.adminPort}

          servers {
            metrics
          }
        '';

        virtualHosts = lib.attrsets.concatMapAttrs makeVirtualHost reverseProxyCfg.virtualHosts;
      };

      promtail.configuration.scrape_configs = lib.mkIf lokiCfg.enable [
        {
          job_name = "caddy";
          static_configs = [
            {
              targets = ["127.0.0.1:${toString cfg.adminPort}"];
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

    systemd.services.caddy.serviceConfig.EnvironmentFile = cfg.environmentFiles;
  };
}
