{
  my,
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.services.prowlarr;

  user = "prowlarr";
  group = "servarr";
  effectiveAddress =
    if cfg.vpnNamespace != null
    then config.vpnNamespaces.${cfg.vpnNamespace}.namespaceAddress
    else "127.0.0.1";
in {
  options.my.services.prowlarr = let
    serviceName = "prowlarr";
  in {
    enable = lib.mkEnableOption serviceName;
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

    users = {
      users.${user} = {
        isSystemUser = true;
        home = cfg.dataDir;
        uid = 2002;
        inherit group;
      };
      groups.${group}.gid = 2002;
    };

    systemd.services.prowlarr = {
      description = "Indexer proxy and manager for Usenet and BitTorrent";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        Type = "simple";
        User = user;
        Group = group;
        ExecStart = "${lib.getExe pkgs.prowlarr} -nobrowser -data=${cfg.dataDir}";
        Restart = "on-failure";
      };

      vpnConfinement = lib.mkIf (cfg.vpnNamespace != null) {
        enable = true;
        inherit (cfg) vpnNamespace;
      };
    };

    systemd.tmpfiles.rules = [
      "d '${cfg.dataDir}' 700 ${user} ${group} - -"
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
