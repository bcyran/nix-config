{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.sabnzbd;
in {
  options.my.services.sabnzbd = let
    serviceName = "SABnzbd";
  in {
    enable = lib.mkEnableOption serviceName;
    user = my.lib.options.mkUserOption serviceName;
    group = my.lib.options.mkGroupOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 8095;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;
  };

  config = lib.mkIf cfg.enable {
    services.sabnzbd = {
      enable = true;
      configFile = null;
      settings = {
        misc = {
          host = cfg.address;
          inherit (cfg) port;
          host_whitelist = cfg.reverseProxy.domain;
        };
      };
      inherit (cfg) user group openFirewall;
      allowConfigWrite = true;
    };

    my.services.caddy.reverseProxyHosts = my.lib.caddy.mkReverseProxy cfg;
  };
}
