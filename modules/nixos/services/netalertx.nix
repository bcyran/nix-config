# NetAlertX needs raw socket access against the host's real network (ARP/mDNS
# scanning), which a rootless podman container cannot get even with
# `--network=host` and `--cap-add=NET_RAW/NET_ADMIN`: the host network
# namespace is owned by the root user namespace, and capabilities granted to a
# rootless container's user namespace aren't honored against a namespace it
# doesn't own. So, unlike most other containerized services here, this one
# runs under the rootful podman backend (no `podman.user`), matching upstream:
# https://github.com/netalertx/NetAlertX/blob/main/install/nix/flake.nix
{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.netalertx;

  # renovate: datasource=docker packageName=ghcr.io/netalertx/netalertx
  imageVersion = "26.10.24";

  dataDir = "/var/lib/netalertx";
  # Fixed, rather than auto-assigned, so that `config.users.users.${cfg.user}.uid`
  # (used for PUID/PGID below) is known at eval time.
  uid = 20211;
in {
  options.my.services.netalertx = let
    serviceName = "NetAlertX";
  in {
    enable = lib.mkEnableOption serviceName;
    user = my.lib.options.mkUserOption serviceName;
    group = my.lib.options.mkGroupOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 20211;
    graphqlPort = my.lib.options.mkPortOption serviceName 20212;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;
    backendApiUrl = lib.mkOption {
      type = lib.types.str;
      default = "http://localhost:${toString cfg.graphqlPort}";
      description = "URL to use when accessing GraphQL server.";
    };
    scanSubnets = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = ["--localnet"];
      example = ["192.168.1.0/24 --interface=eth0"];
      description = ''
        Subnets (optionally with an explicit `--interface=`) for the ARPSCAN
        plugin to scan. Because this runs with `--network=host`, interface
        names are the host's own (e.g. `enp5s0`), not container-internal ones.
        Note that NetAlertX resolves and persists `--localnet` into a concrete
        subnet/interface on first use, so changing this afterwards may
        require also updating it in the Settings UI.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port cfg.graphqlPort];

    users = {
      users = lib.mkIf (cfg.user == "netalertx") {
        netalertx = {
          isSystemUser = true;
          group = lib.mkForce cfg.group;
          inherit uid;
        };
      };
      groups = lib.mkIf (cfg.group == "netalertx") {netalertx.gid = uid;};
    };

    virtualisation.oci-containers.containers.netalertx = {
      image = "ghcr.io/netalertx/netalertx:${imageVersion}";
      autoStart = true;
      volumes = [
        "${dataDir}:/data"
        "/etc/localtime:/etc/localtime:ro"
      ];
      environment = {
        PUID = toString config.users.users.${cfg.user}.uid;
        PGID = toString config.users.groups.${cfg.group}.gid;
        LISTEN_ADDR = cfg.address;
        PORT = toString cfg.port;
        GRAPHQL_PORT = toString cfg.graphqlPort;
        APP_CONF_OVERRIDE = builtins.toJSON {
          BACKEND_API_URL = cfg.backendApiUrl;
          SCAN_SUBNETS = cfg.scanSubnets;
        };
        ALWAYS_FRESH_INSTALL = "false";
        NETALERTX_DEBUG = "0";
      };
      extraOptions = [
        "--network=host"
        "--cap-drop=ALL"
        "--cap-add=NET_ADMIN"
        "--cap-add=NET_RAW"
        "--cap-add=NET_BIND_SERVICE"
        "--cap-add=CHOWN"
        "--cap-add=SETUID"
        "--cap-add=SETGID"
        "--read-only"
        "--tmpfs=/tmp"
      ];
    };

    systemd.tmpfiles.rules = [
      "d '${dataDir}' 0750 ${cfg.user} ${cfg.group} - -"
      "d '${dataDir}/db' 0750 ${cfg.user} ${cfg.group} - -"
      "d '${dataDir}/config' 0750 ${cfg.user} ${cfg.group} - -"
    ];

    my.services.caddy.reverseProxyHosts = my.lib.caddy.mkReverseProxy cfg;
  };
}
