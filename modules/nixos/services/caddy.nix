{
  inputs,
  pkgs,
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.caddy;
  reverseProxyCfg = config.my.reverseProxy;
  lokiCfg = config.my.services.loki;

  grafanaDashboardsLib = inputs.grafana-dashboards.lib {inherit pkgs;};
  caddyWithOvhDnsPlugin = pkgs.caddy.withPlugins {
    plugins = ["github.com/caddy-dns/ovh@v0.0.3"];
    hash = "sha256-Z+jRwGQRHJZFQnEoqA0IV0otsD4IC1cPZqywMj++JS0";
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

    # NOTE: This is needed becase `mode 644` in `extraConfig` doesn't work yet in the current
    #       version of Caddy. Remove this once it works.
    #       We need the logs to be world readable so Promtail can read them.
    systemd = {
      services.caddy-log-chmod = {
        description = "Make Caddy logs world readable";
        serviceConfig.Type = "oneshot";
        script = ''
          ${pkgs.coreutils}/bin/chmod 755 /var/log/caddy
          ${pkgs.coreutils}/bin/chmod 644 /var/log/caddy/*
        '';
      };
      timers.caddy-log-chmod = {
        wantedBy = ["timers.target"];
        after = ["caddy.service"];
        requires = ["caddy.service"];
        timerConfig = {
          OnCalendar = "hourly";
        };
      };
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

    systemd.services.caddy.serviceConfig.EnvironmentFile = cfg.environmentFiles;
  };
}
