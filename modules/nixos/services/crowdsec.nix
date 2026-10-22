{
  inputs,
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.crowdsec;

  grafanaDashboardsLib = inputs.grafana-dashboards.lib {inherit pkgs;};
  crowdsecPrometheusJobName = "crowdsec";
in {
  options.my.services.crowdsec = {
    enable = lib.mkEnableOption "crowdsec";

    consoleTokenFile = lib.mkOption {
      type = with lib.types; nullOr path;
      default = null;
      description = "Path to the file containing CrowdSec Console token.";
    };

    capiCredentialsFile = lib.mkOption {
      type = with lib.types; nullOr path;
      default = null;
      description = "Path to the file containing CrowdSec Central API credentials.";
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      crowdsec = {
        enable = true;
        hub.collections = [
          "crowdsecurity/linux"
          "crowdsecurity/caddy"
        ];
        autoUpdateService = true;
        settings = {
          config.api.server.online_client.credentials_path = cfg.capiCredentialsFile;
          console.enrollKeyFile = cfg.consoleTokenFile;
          acquisitions = [
            {
              journalctl_filter = ["_SYSTEMD_UNIT=sshd.service"];
              labels.type = "syslog";
              source = "journalctl";
            }
            {
              labels.type = "caddy";
              filenames = ["/var/log/caddy/access-*.log"];
            }
          ];
        };
      };

      crowdsec-firewall-bouncer = {
        enable = true;
      };

      prometheus.scrapeConfigs = lib.mkIf config.services.prometheus.enable [
        {
          job_name = crowdsecPrometheusJobName;
          static_configs = [
            {
              targets = ["127.0.0.1:6060"];
            }
          ];
        }
      ];

      grafana = lib.mkIf config.services.grafana.enable {
        provision = {
          dashboards.settings.providers = [
            (grafanaDashboardsLib.dashboardEntry {
              name = "crowdsec";
              path = grafanaDashboardsLib.fetchDashboard {
                name = "crowdsec-v6";
                id = 21419;
                version = 6;
                hash = "sha256-OlqgFmmjtiXMxLMOsiW66rZ7YnXg5CKU3pno0boa1Ho=";
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
  };
}
