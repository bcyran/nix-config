{
  my,
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.services.prowlarr;

  effectiveAddress =
    if cfg.vpnNamespace != null
    then config.vpnNamespaces.${cfg.vpnNamespace}.namespaceAddress
    else "127.0.0.1";
in {
  options.my.services.prowlarr = let
    serviceName = "prowlarr";
  in {
    enable = lib.mkEnableOption serviceName;
    user = my.lib.options.mkUserOption serviceName;
    group = my.lib.options.mkGroupOption serviceName;
    port = my.lib.options.mkPortOption serviceName 9696;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;
    dataDir = my.lib.options.mkDataDirOption serviceName "/var/lib/prowlarr";

    vpnNamespace = lib.mkOption {
      type = with lib.types; nullOr str;
      default = null;
      example = "proton";
      description = "The name of the VPN namespace. VPN is disabled if not given.";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];

    systemd.services.prowlarr = {
      description = "Indexer proxy and manager for Usenet and BitTorrent";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        ExecStart = "${lib.getExe pkgs.prowlarr} -nobrowser -data=${cfg.dataDir}";
        Restart = "on-failure";
      };

      vpnConfinement = lib.mkIf (cfg.vpnNamespace != null) {
        enable = true;
        inherit (cfg) vpnNamespace;
      };
    };

    users = {
      users = lib.mkIf (cfg.user == "prowlarr") {
        prowlarr = {
          name = "prowlarr";
          isSystemUser = true;
          inherit (cfg) group;
        };
        groups = lib.mkIf (cfg.group == "prowlarr") {prowlarr = {};};
      };
    };

    systemd.tmpfiles.rules = [
      "d '${cfg.dataDir}' 700 ${cfg.user} ${cfg.group} - -"
    ];

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
