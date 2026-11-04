{
  my,
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.cockpit;
in {
  options.my.services.cockpit = let
    serviceName = "Cockpit";
  in {
    enable = lib.mkEnableOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 9092;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;
  };

  config = lib.mkIf cfg.enable {
    services.cockpit = {
      enable = true;
      inherit (cfg) port openFirewall;
      allowed-origins = ["https://${cfg.reverseProxy.domain}"];
      plugins = with pkgs; [
        cockpit-machines
      ];
    };

    my.services.caddy.reverseProxyHosts = my.lib.caddy.mkReverseProxy cfg;
  };
}
