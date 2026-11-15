{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.coolercontrol;
in {
  options.my.services.coolercontrol = let
    serviceName = "CoolerControl";
  in {
    enable = lib.mkEnableOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 11987;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;
  };

  config = lib.mkIf cfg.enable {
    programs.coolercontrol.enable = true;

    systemd.services.coolercontrold.environment = {
      CC_HOST_IP4 = cfg.address;
      CC_PORT = toString cfg.port;
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];

    my.services.caddy.reverseProxyHosts = my.lib.caddy.mkReverseProxy cfg;
  };
}
