{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.grafana;
in {
  options.my.services.grafana = let
    serviceName = "Grafana";
  in {
    enable = lib.mkEnableOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 3000;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];

    services = {
      grafana = {
        enable = true;

        settings = {
          server = {
            http_addr = cfg.address;
            http_port = cfg.port;
            enforce_domain = false;
            enable_gzip = true;
            inherit (cfg.reverseProxy) domain;
          };
          analytics.reporting_enabled = false;
        };
      };
    };

    my.services.caddy.reverseProxyHosts = lib.optionalAttrs (cfg.reverseProxy.domain != null) {
      ${cfg.reverseProxy.domain} = {
        upstreamAddress = cfg.address;
        upstreamPort = cfg.port;
      };
    };
  };
}
