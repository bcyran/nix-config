{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.prometheus;
in {
  options.my.services.prometheus = let
    serviceName = "Prometheus";
  in {
    enable = lib.mkEnableOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 9090;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];

    services = {
      prometheus = {
        enable = true;
        listenAddress = cfg.address;
        inherit (cfg) port;

        webExternalUrl = "https://${cfg.reverseProxy.domain}";

        globalConfig = {
          scrape_interval = "15s";
          evaluation_interval = "15s";
        };

        exporters = {
          node = {
            enable = true;
            enabledCollectors = [
              "systemd"
              "processes"
            ];
            port = 9100;
            disabledCollectors = [
              # This errors out on my system and I don't really care about it.
              "powersupplyclass"
            ];
          };
        };

        scrapeConfigs = [
          {
            job_name = "node";
            static_configs = [
              {
                targets = ["127.0.0.1:${toString config.services.prometheus.exporters.node.port}"];
              }
            ];
          }
        ];
      };
    };

    my.services.caddy.reverseProxyHosts = my.lib.caddy.mkReverseProxy cfg;
  };
}
