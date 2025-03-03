{
  my,
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.services.transmission;

  effectiveAddress =
    if cfg.vpnNamespace != null
    then config.vpnNamespaces.${cfg.vpnNamespace}.namespaceAddress
    else cfg.address;
in {
  options.my.services.transmission = let
    serviceName = "Transmission";
  in {
    enable = lib.mkEnableOption serviceName;
    user = my.lib.options.mkUserOption serviceName;
    group = my.lib.options.mkGroupOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 9091;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;
    dataDir = my.lib.options.mkDataDirOption serviceName "/var/lib/transmission";

    peerPort = lib.mkOption {
      type = lib.types.int;
      default = 51413;
      example = 51413;
      description = "The port that Transmission should use for incoming connections.";
    };

    downloadsDir = lib.mkOption {
      type = lib.types.path;
      example = "/path/to/downloads";
      description = "The path to the directory where Transmission should save downloaded files.";
    };

    credentialsFile = lib.mkOption {
      type = lib.types.path;
      example = "/path/to/credentials/file";
      description = "The path to the credentials JSON file for the Transmission service.";
    };

    vpnNamespace = lib.mkOption {
      type = with lib.types; nullOr str;
      default = null;
      example = "proton";
      description = "The name of the VPN namespace. VPN is disabled if not given.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.transmission = {
      enable = true;
      home = cfg.dataDir;
      webHome = pkgs.flood-for-transmission;
      openPeerPorts = cfg.openFirewall;
      openRPCPort = cfg.openFirewall;
      inherit (cfg) user group credentialsFile;

      settings = {
        download-dir = cfg.downloadsDir;
        incomplete-dir-enabled = true;
        incomplete-dir = "${cfg.downloadsDir}/.incomplete";
        watch-dir-enabled = true;
        watch-dir = "${cfg.downloadsDir}/.watch";

        peer-port = cfg.peerPort;
        port-forwarding-enabled = false;

        rpc-bind-address = effectiveAddress;
        rpc-port = cfg.port;
        rpc-whitelist-enabled = false;
        rpc-authentication-required = true;
        rpc-host-whitelist-enabled = true;
        rpc-host-whitelist = builtins.concatStringsSep "," ["localhost" cfg.reverseProxy.domain];

        blocklist-enabled = true;
        blocklist-url = "https://github.com/Naunter/BT_BlockLists/raw/master/bt_blocklists.gz";

        anti-brute-force-enabled = true;
        anti-brute-force-threshold = 10;
      };
    };

    systemd.tmpfiles.rules = [
      "d '${cfg.dataDir}'                    0700 ${cfg.user} ${cfg.group} - -"
      "d '${cfg.downloadsDir}'               0755 ${cfg.user} ${cfg.group} - -"
      "d '${cfg.downloadsDir}/.incomplete'   0755 ${cfg.user} ${cfg.group} - -"
      "d '${cfg.downloadsDir}/.watch'        0755 ${cfg.user} ${cfg.group} - -"
      "d '${cfg.downloadsDir}/books'         0755 ${cfg.user} ${cfg.group} - -"
      "d '${cfg.downloadsDir}/movies'        0755 ${cfg.user} ${cfg.group} - -"
      "d '${cfg.downloadsDir}/music'         0755 ${cfg.user} ${cfg.group} - -"
      "d '${cfg.downloadsDir}/tv'            0755 ${cfg.user} ${cfg.group} - -"
    ];

    systemd.services.transmission.vpnConfinement = lib.mkIf (cfg.vpnNamespace != null) {
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
      openVPNPorts = [
        {
          port = cfg.peerPort;
          protocol = "both";
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
