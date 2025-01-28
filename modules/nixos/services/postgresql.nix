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

  effectiveDataDir = "${cfg.dataDir}/${config.services.postgresql.package.psqlSchema}";
  dumpDir = "${cfg.dataDir}/dump";

  postgresExporterUser = "postgres-exporter";
  postgresExporterPort = 9187;
in {
  options.my.services.postgresql = let
    serviceName = "PostgreSQL";
  in {
    enable = lib.mkEnableOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 5432;
    dataDir = my.lib.options.mkDataDirOption serviceName "/var/lib/postgresql";
  };

  config = lib.mkIf cfg.enable {
    services = {
      postgresql = {
        enable = true;
        dataDir = effectiveDataDir;

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
        location = dumpDir;
        startAt = "*-*-* 00:00:00";
      };

      prometheus = lib.mkIf prometheusCfg.enable {
        exporters.postgres = {
          enable = true;
          user = postgresExporterUser;
          dataSourceName = "postgresql:///postgres?host=/run/postgresql";
          port = postgresExporterPort;
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

    systemd.tmpfiles.rules = [
      "d '${effectiveDataDir}' 0750 postgres postgres - -"
      "d '${dumpDir}' 0750 postgres postgres - -"
    ];
  };
}
