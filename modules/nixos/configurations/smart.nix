{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.configurations.smart;
  grafanaDashboardsLib = inputs.grafana-dashboards.lib {inherit pkgs;};
in {
  options.my.configurations.smart = let
    serviceName = "S.M.A.R.T. monitoring";
  in {
    enable = lib.mkEnableOption serviceName;
  };

  config = lib.mkIf cfg.enable {
    services = {
      prometheus = {
        exporters.smartctl = {
          enable = true;
          user = "root";
        };
        scrapeConfigs = [
          {
            job_name = "smartctl";
            static_configs = [
              {
                targets = ["127.0.0.1:${toString config.services.prometheus.exporters.smartctl.port}"];
              }
            ];
          }
        ];
      };

      grafana.provision.dashboards.settings.providers = [
        (grafanaDashboardsLib.dashboardEntry {
          name = "smartctl";
          path = grafanaDashboardsLib.fetchDashboard {
            name = "smartctl";
            id = 22604;
            version = 2;
            hash = "sha256-I6iGSkqduo8uaf2xSwMRuxKPeq+tEnbpmisGEZs6Ucw=";
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
}
