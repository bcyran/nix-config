{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.sonarr;

  user = "sonarr";
  group = "servarr";
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

    mediaDir = lib.mkOption {
      type = lib.types.path;
      example = "/path/to/media";
      description = "The path to the directory where Sonarr should store media files.";
    };

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
      inherit user group;
      inherit (cfg) dataDir openFirewall;
    };

    systemd.tmpfiles.rules = [
      "d '${cfg.dataDir}'   0750 ${user} ${group} - -"
      "d '${cfg.mediaDir}'  0770 ${user} ${group} - -"
    ];

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
