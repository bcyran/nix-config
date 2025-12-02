{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.audiobookshelf;
in {
  options.my.services.audiobookshelf = let
    serviceName = "Audiobookshelf";
  in {
    enable = lib.mkEnableOption serviceName;
    user = my.lib.options.mkUserOption serviceName;
    group = my.lib.options.mkGroupOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 8094;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;
  };

  config = lib.mkIf cfg.enable {
    services.audiobookshelf = {
      enable = true;
      host = cfg.address;
      inherit (cfg) port user group openFirewall;
    };

    my.services.caddy.reverseProxyHosts = my.lib.caddy.mkReverseProxy cfg;
  };
}
