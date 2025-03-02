{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.radarr;

  user = "radarr";
  group = "servarr";
  effectiveAddress =
    if cfg.vpnNamespace != null
    then config.vpnNamespaces.${cfg.vpnNamespace}.namespaceAddress
    else "127.0.0.1";
in {
  options.my.services.radarr = let
    serviceName = "Radarr";
  in {
    enable = lib.mkEnableOption serviceName;
    port = my.lib.options.mkPortOption serviceName 7878;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;
    dataDir = my.lib.options.mkDataDirOption serviceName "/var/lib/radarr";

    mediaDir = lib.mkOption {
      type = lib.types.path;
      example = "/path/to/media";
      description = "The path to the directory where Radarr should store media files.";
    };

    vpnNamespace = lib.mkOption {
      type = with lib.types; nullOr str;
      default = null;
      example = "proton";
      description = "The name of the VPN namespace. VPN is disabled if not given.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.radarr = {
      enable = true;
      inherit user group;
      inherit (cfg) openFirewall dataDir;
    };

    systemd.tmpfiles.rules = [
      "d '${cfg.dataDir}'   0700 ${user} ${group} - -"
      "d '${cfg.mediaDir}'  0775 ${user} ${group} - -"
    ];

    systemd.services.radarr.vpnConfinement = lib.mkIf (cfg.vpnNamespace != null) {
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
