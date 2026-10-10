{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.drawio;

  # renovate: datasource=docker packageName=docker.io/jgraph/drawio
  imageVersion = "31.7.0";
  dataDir = "/var/lib/drawio";
  uid = 2002;
in {
  options.my.services.drawio = let
    serviceName = "draw.io";
  in {
    enable = lib.mkEnableOption serviceName;
    user = (my.lib.options.mkUserOption serviceName) // {default = "drawio";};
    group = (my.lib.options.mkGroupOption serviceName) // {default = "drawio";};
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 8087;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];

    virtualisation.oci-containers.containers.drawio = {
      image = "docker.io/jgraph/drawio:${imageVersion}";
      autoStart = true;
      ports = ["${cfg.address}:${builtins.toString cfg.port}:8080"];
      podman.user = cfg.user;
      extraOptions = [
        "--cap-drop=ALL"
        "--security-opt=no-new-privileges"
      ];
    };

    users = rec {
      users.${cfg.user} = {
        home = dataDir;
        createHome = true;
        inherit (cfg) group;
        inherit uid;
        isSystemUser = true;
        autoSubUidGidRange = true;
        linger = true;
      };
      groups.${cfg.group}.gid = users.${cfg.user}.uid;
    };

    systemd.tmpfiles.rules = [
      "d '/var/lib/containers/rootless/${toString uid}' 0700 ${cfg.user} ${cfg.group} - -"
    ];

    my.services.caddy.reverseProxyHosts = my.lib.caddy.mkReverseProxy cfg;
  };
}
