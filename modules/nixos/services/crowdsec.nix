{
  config,
  lib,
  ...
}: let
  cfg = config.my.services.crowdsec;
in {
  options.my.services.crowdsec.enable = lib.mkEnableOption "crowdsec";

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
    };
  };
}
