{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.changedetection;
in {
  options.my.services.changedetection = let
    serviceName = "changedetection";
  in {
    enable = lib.mkEnableOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 8100;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;
    environmentFile = my.lib.options.mkEnvironmentFileOption serviceName;
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];

    services.changedetection-io = {
      enable = true;
      listenAddress = cfg.address;
      baseURL = cfg.address;
      inherit (cfg) port environmentFile;
    };

    my.services.caddy.reverseProxyHosts = my.lib.caddy.mkReverseProxy cfg;
  };
}
