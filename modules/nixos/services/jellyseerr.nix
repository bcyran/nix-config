{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.jellyseerr;
in {
  options.my.services.jellyseerr = let
    serviceName = "jellyseerr";
  in {
    enable = lib.mkEnableOption serviceName;
    port = my.lib.options.mkPortOption serviceName 5055;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;
  };

  config = lib.mkIf cfg.enable {
    services.jellyseerr = {
      enable = true;
      configDir = "/var/lib/jellyseerr";
      inherit (cfg) port openFirewall;
    };

    my.services.caddy.reverseProxyHosts = lib.optionalAttrs (cfg.reverseProxy.domain != null) {
      ${cfg.reverseProxy.domain} = {
        upstreamAddress = "127.0.0.1";
        upstreamPort = cfg.port;
      };
    };
  };
}
