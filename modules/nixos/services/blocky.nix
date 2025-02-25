{
  my,
  inputs,
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (my.lib.const) dns;
  cfg = config.my.services.blocky;

  grafanaDashboardsLib = inputs.grafana-dashboards.lib {inherit pkgs;};
  blockyPrometheusJobName = "blocky";
  pgDatabase = "blocky";
  grafanaPostgresDatasourceName = "Blocky Postgres";
in {
  options.my.services.blocky = let
    serviceName = "blocky DNS proxy";
  in {
    enable = lib.mkEnableOption serviceName;
    dnsAddress = my.lib.options.mkAddressOption serviceName;
    dnsPort = my.lib.options.mkPortOption serviceName 53;
    httpAddress = my.lib.options.mkAddressOption serviceName;
    httpPort = my.lib.options.mkPortOption serviceName 4000;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;

    customDNSMappings = lib.mkOption {
      type = with lib.types; attrsOf str;
      default = {};
      description = "Custom DNS mappings.";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [cfg.dnsPort];
      allowedUDPPorts = [cfg.dnsPort];
    };

    services = {
      blocky = {
        enable = true;
        settings = {
          ports = {
            dns = "${cfg.dnsAddress}:${toString cfg.dnsPort}";
            http = "${cfg.httpAddress}:${toString cfg.httpPort}";
          };
          upstreams.groups.default = dns.https;
          bootstrapDns =
            map (resolver: {
              upstream = resolver.https;
              inherit (resolver) ips;
            })
            dns.resolvers;
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
          queryLog = {
            type = "postgresql";
            target = "postgresql:///${pgDatabase}?host=/run/postgresql";
            logRetentionDays = 30;
          };
        };
      };

      postgresql = {
        ensureDatabases = [pgDatabase];
        ensureUsers = [
          {
            name = pgDatabase;
            ensureDBOwnership = true;
            ensureClauses.login = true;
          }
        ];
        authentication = ''
          local ${pgDatabase} ${pgDatabase} trust
        '';
      };

      prometheus.scrapeConfigs = lib.mkIf config.services.prometheus.enable [
        {
          job_name = blockyPrometheusJobName;
          static_configs = [
            {
              targets = ["127.0.0.1:${toString cfg.httpPort}"];
            }
          ];
        }
      ];

      grafana = lib.mkIf config.services.grafana.enable {
        settings.panels.disable_sanitize_html = true;

        provision = {
          datasources.settings.datasources = [
            {
              name = grafanaPostgresDatasourceName;
              type = "postgres";
              url = "/run/postgresql";
              user = pgDatabase;
              secureJsonData = {
                password = "-";
              };
              jsonData = {
                database = pgDatabase;
                sslmode = "disable";
              };
            }
          ];

          dashboards.settings.providers = [
            (grafanaDashboardsLib.dashboardEntry {
              name = "blocky";
              path = grafanaDashboardsLib.fetchDashboard {
                name = "blocky-v6";
                id = 13768;
                version = 6;
                hash = "sha256-Kxgu2YD6MKjtAZlxiIxOgywLtfPs7cjMBUNjYsdtmE8";
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
            (grafanaDashboardsLib.dashboardEntry {
              name = "blocky-postgres";
              path = grafanaDashboardsLib.fetchDashboard {
                name = "blocky-postgres-v12";
                id = 17996;
                version = 12;
                hash = "sha256-G+iVF/bmMsxZBVT9hqAHHMN1nvIgpYn3VnFPc+Ew3XU=";
              };
              transformations = grafanaDashboardsLib.fillTemplating [
                {
                  key = "DS_BLOCKY-POSTGRESQL";
                  value = grafanaPostgresDatasourceName;
                }
              ];
            })
          ];
        };
      };
    };
  };
}
