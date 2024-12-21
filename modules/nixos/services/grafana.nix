{
  config,
  lib,
  ...
}: let
  cfg = config.my.services.grafana;
in {
  options.my.services.grafana = {
    enable = lib.mkEnableOption "grafana";

    domain = lib.mkOption {
      type = lib.types.str;
      example = "grafana.home.my.tld";
      description = "The domain on which the Grafana server listens.";
    };

    port = lib.mkOption {
      type = lib.types.int;
      default = 3000;
      description = "The port on which the Grafana server listens.";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [cfg.port];

    services = {
      grafana = {
        enable = true;
        settings = {
          server = {
            http_addr = "127.0.0.1";
            http_port = cfg.port;
            enforce_domain = true;
            enable_gzip = true;
            inherit (cfg) domain;
          };
          analytics.reporting_enabled = false;
        };
      };
    };

    my.services.reverseProxy.virtualHosts.${cfg.domain} = let
      inherit (config.services.grafana.settings.server) http_addr http_port;
    in {
      backendAddress = http_addr;
      backendPort = http_port;
    };
  };
}
