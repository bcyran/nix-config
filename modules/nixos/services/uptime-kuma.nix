{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.uptime-kuma;
in {
  options.my.services.uptime-kuma = let
    serviceName = "Uptime Kuma";
  in {
    enable = lib.mkEnableOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 8081;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    domain = my.lib.options.mkDomainOption serviceName;
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];

    services.uptime-kuma = {
      enable = true;
      settings = {
        UPTIME_KUMA_HOST = cfg.address;
        UPTIME_KUMA_PORT = builtins.toString cfg.port;
      };
    };

    my.reverseProxy.virtualHosts.${cfg.domain} = lib.mkIf (cfg.domain != null) {
      backendAddress = "127.0.0.1";
      backendPort = cfg.port;
    };
  };
}
