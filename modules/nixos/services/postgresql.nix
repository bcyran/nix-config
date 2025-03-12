{
  inputs,
  pkgs,
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.postgresql;
  prometheusCfg = config.my.services.prometheus;

  grafanaDashboardsLib = inputs.grafana-dashboards.lib {inherit pkgs;};

  postgresExporterUser = "postgres-exporter";
  postgresExporterPort = 9187;
in {
  options.my.services.postgresql = let
    serviceName = "PostgreSQL";
  in {
    enable = lib.mkEnableOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 5432;
  };

  config = lib.mkIf cfg.enable {
    services = {
      postgresql = {
        enable = true;

        settings = {
          listen_addresses = lib.mkForce cfg.address;
          inherit (cfg) port;
        };

        ensureUsers = lib.mkIf prometheusCfg.enable [
          {
            name = postgresExporterUser;
          }
        ];
        authentication = lib.mkIf prometheusCfg.enable ''
          local postgres ${postgresExporterUser} trust
        '';
      };

      postgresqlBackup = {
        enable = true;
        backupAll = true;
        compression = "zstd";
        location = "${config.services.postgresql.dataDir}/dump";
        startAt = "*-*-* 00:00:00";
      };

      prometheus = lib.mkIf prometheusCfg.enable {
        exporters.postgres = {
          enable = true;
          user = postgresExporterUser;
          dataSourceName = "postgresql:///postgres?host=/run/postgresql";
          port = postgresExporterPort;
          # Running as non-superuser requires additional configuration to collect some metrics (WAL).
          # Also, some DBs can't be accessed and seem to require additional permissions.
          # It's a PITA in general.
          runAsLocalSuperUser = true;
        };
        scrapeConfigs = [
          {
            job_name = "postgres";
            static_configs = [
              {
                targets = ["127.0.0.1:${toString postgresExporterPort}"];
              }
            ];
          }
        ];
      };

      grafana = lib.mkIf config.services.grafana.enable {
        settings.panels.disable_sanitize_html = true;

        provision.dashboards.settings.providers = [
          (grafanaDashboardsLib.dashboardEntry {
            name = "postgres";
            path = grafanaDashboardsLib.fetchDashboard {
              name = "postgres";
              id = 9628;
              version = 8;
              hash = "sha256-VDX4BfGbY3PW5YHcRilg4g6+6uN22EK5+r+Ph67xXAY";
            };
            transformations = grafanaDashboardsLib.fillTemplating [
              {
                key = "DS_PROMETHEUS";
                value = "Prometheus";
              }
            ];
          })
        ];
      };
    };
  };
}
