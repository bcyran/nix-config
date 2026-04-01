{
  inputs,
  pkgs,
  config,
  lib,
  ...
}: let
  bouncerUpstreamCfg = config.services.crowdsec-firewall-bouncer;
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
          general.api.server.enable = true;
          lapi.credentialsFile = "/var/lib/crowdsec/local_api_credentials.yaml";
          capi.credentialsFile = cfg.capiCredentialsFile;
          console.tokenFile = cfg.consoleTokenFile;
        };
        localConfig = {
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

    # Fix "mkdir: cannot create directory '/var/lib/crowdsec': Permission denied"
    systemd.services.crowdsec.serviceConfig.StateDirectory = "crowdsec";

    # TODO: Remove when fixed upstream: https://github.com/NixOS/nixpkgs/pull/500515
    systemd.services.crowdsec-firewall-bouncer-register.script = let
      apiKeyFile = "/var/lib/crowdsec-firewall-bouncer-register/api-key.cred";
    in
      lib.mkForce ''
        # Need to use a `cscli` wrapper which sets `--config` to correct path.
        cscli=/run/current-system/sw/bin/cscli
        if $cscli bouncers list --output json | ${lib.getExe pkgs.jq} -e -- ${lib.escapeShellArg "any(.[]; .name == \"${bouncerUpstreamCfg.registerBouncer.bouncerName}\")"} >/dev/null; then
          # Bouncer already registered. Verify the API key is still present
          if [ ! -f ${apiKeyFile} ]; then
            echo "Bouncer registered but API key is not present"
            exit 1
          fi
        else
          # Bouncer not registered
          # Remove any previously saved API key
          rm -f '${apiKeyFile}'
          # Register the bouncer and save the new API key
          if ! $cscli bouncers add --output raw -- ${lib.escapeShellArg bouncerUpstreamCfg.registerBouncer.bouncerName} >${apiKeyFile}; then
            # Failed to register the bouncer
            rm ${apiKeyFile}
            exit 1
          fi
        fi
      '';
  };
}
