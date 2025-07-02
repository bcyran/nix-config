{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.pinchflat;

  effectiveAddress =
    if cfg.vpnNamespace != null
    then config.vpnNamespaces.${cfg.vpnNamespace}.namespaceAddress
    else "127.0.0.1";
in {
  options.my.services.pinchflat = let
    serviceName = "Pinchflat";
  in {
    enable = lib.mkEnableOption serviceName;
    user = my.lib.options.mkUserOption serviceName;
    group = my.lib.options.mkGroupOption serviceName;
    port = my.lib.options.mkPortOption serviceName 8945;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;
    environmentFile = my.lib.options.mkEnvironmentFileOption serviceName;

    mediaDir = lib.mkOption {
      type = lib.types.path;
      example = "/path/to/media";
      description = "The path to the directory where ${serviceName} should store media files.";
    };

    vpnNamespace = lib.mkOption {
      type = with lib.types; nullOr str;
      default = null;
      example = "proton";
      description = "The name of the VPN namespace. VPN is disabled if not given.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.pinchflat = {
      enable = true;
      inherit (cfg) port mediaDir openFirewall;
      secretsFile = cfg.environmentFile;

      extraConfig = {
        ENABLE_IPV6 = "true";
      };
    };

    users = {
      users = lib.mkIf (cfg.user == "pinchflat") {
        pinchflat = {
          name = "pinchflat";
          isSystemUser = true;
          group = lib.mkForce cfg.group;
        };
      };
      groups = lib.mkIf (cfg.group == "pinchflat") {pinchflat = {};};
    };

    systemd.tmpfiles.rules = [
      "d '${cfg.mediaDir}' 0775 ${cfg.user} ${cfg.group} - -"
    ];

    systemd.services.pinchflat = {
      # We need a permanent user to grant permissions to the media directory.
      serviceConfig = {
        User = cfg.user;
        DynamicUser = lib.mkForce false;
      };
      vpnConfinement = lib.mkIf (cfg.vpnNamespace != null) {
        enable = true;
        inherit (cfg) vpnNamespace;
      };
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
