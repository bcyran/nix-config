{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.apprise;

  # renovate: datasource=docker packageName=docker.io/caronc/apprise
  imageVersion = "2.0.2";
  dataDir = "/var/lib/apprise";
  uid = 2004;
in {
  options.my.services.apprise = let
    serviceName = "Apprise";
  in {
    enable = lib.mkEnableOption serviceName;
    user = my.lib.options.mkUserOption serviceName;
    group = my.lib.options.mkGroupOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 8098;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];

      virtualisation.oci-containers.containers.apprise = {
        image = "docker.io/caronc/apprise:v${imageVersion}";
        autoStart = true;
        ports = ["${cfg.address}:${builtins.toString cfg.port}:8000"];
        volumes = [
          "${dataDir}/config:/config"
        ];
        environment = {
          PUID = toString config.users.users.${cfg.user}.uid;
          PGID = toString config.users.groups.${cfg.group}.gid;
          APPRISE_STATEFUL_MODE = "simple";
          APPRISE_WORKER_COUNT = "1";
        };
        extraOptions = [
          # Expose host's loopback interface in the container as 10.0.2.2.
          "--network=slirp4netns:allow_host_loopback=true"
          "--userns=keep-id"
          "--cap-drop=ALL"
          "--security-opt=no-new-privileges"
        ];
        podman.user = cfg.user;
      };

      systemd.tmpfiles.rules = [
        "d '${dataDir}' 0750 ${cfg.user} ${cfg.group} - -"
        "d '${dataDir}/config' 0750 ${cfg.user} ${cfg.group} - -"
      ];

      my.services.caddy.reverseProxyHosts = my.lib.caddy.mkReverseProxy cfg;
    }

    (my.lib.ociContainers.mkRootlessPodmanUser {
      inherit (cfg) user group;
      home = dataDir;
      inherit uid;
    })
  ]);
}
