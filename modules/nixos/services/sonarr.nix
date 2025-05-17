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
    else "127.0.0.1";
in {
  options.my.services.sonarr = let
    serviceName = "sonarr";
  in {
    enable = lib.mkEnableOption serviceName;
    user = my.lib.options.mkUserOption serviceName;
    group = my.lib.options.mkGroupOption serviceName;
    port = my.lib.options.mkPortOption serviceName 8989;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;

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
      dataDir = "/var/lib/sonarr";
      inherit (cfg) user group openFirewall;
      settings.server.port = cfg.port;
    };

    systemd.tmpfiles.rules = [
      "d '${cfg.mediaDir}'  0775 ${cfg.user} ${cfg.group} - -"
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
