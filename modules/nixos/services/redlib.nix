{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.redlib;
in {
  options.my.services.redlib = let
    serviceName = "redlib";
  in {
    enable = lib.mkEnableOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 8091;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;
  };

  config = lib.mkIf cfg.enable {
    services.redlib = {
      enable = true;
      inherit (cfg) address port openFirewall;
    };

    my.services.caddy.reverseProxyHosts = my.lib.caddy.mkReverseProxy cfg;
  };
}
