{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.sonarr;

  effectiveAddress =
    if cfg.vpnNamespace != null
    then config.vpnNamespaces.${cfg.vpnNamespace}.namespaceAddress
    else cfg.address;
in {
  options.my.services.sonarr = let
    serviceName = "sonarr";
  in {
    enable = lib.mkEnableOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 8989;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;
    dataDir = my.lib.options.mkDataDirOption serviceName "/var/lib/sonarr";

    vpnNamespace = lib.mkOption {
      type = with lib.types; nullOr str;
      default = null;
      example = "proton";
      description = "The name of the VPN namespace. VPN is disabled if not given.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.sonarr = {
      enable = true;
      user = "sonarr";
      group = "sonarr";
      inherit (cfg) dataDir openFirewall;
    };

    systemd.services.sonarr.vpnConfinement = lib.mkIf (cfg.vpnNamespace != null) {
      enable = true;
      inherit (cfg) vpnNamespace;
    };

    vpnNamespaces.${cfg.vpnNamespace} = lib.mkIf (cfg.vpnNamespace != null) {
      enable = true;
      portMappings = [
        {
          from = cfg.port;
          to = cfg.port;
        }
      ];
    };

    my.services.caddy.reverseProxyHosts = lib.optionalAttrs (cfg.reverseProxy.domain != null) {
      ${cfg.reverseProxy.domain} = {
        upstreamAddress = effectiveAddress;
        upstreamPort = cfg.port;
      };
    };
  };
}
