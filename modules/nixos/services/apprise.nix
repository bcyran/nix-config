{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.apprise;

  appriseVersion = "1.3.1";
  user = "apprise";
  group = "apprise";
  dataDir = "/var/lib/apprise";
in {
  options.my.services.apprise = let
    serviceName = "Apprise";
  in {
    enable = lib.mkEnableOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 8098;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];

    virtualisation.oci-containers.containers.apprise = {
      image = "caronc/apprise:${appriseVersion}";
      autoStart = true;
      ports = ["${cfg.address}:${builtins.toString cfg.port}:8000"];
      volumes = [
        "${dataDir}/config:/config"
      ];
      environment = {
        PUID = toString config.users.users.${user}.uid;
        PGID = toString config.users.groups.${group}.gid;
        APPRISE_STATEFUL_MODE = "simple";
        APPRISE_WORKER_COUNT = "1";
      };
      extraOptions = [
        # Expose host's loopback interface in the container as 10.0.2.2.
        "--network=slirp4netns:allow_host_loopback=true"
      ];
    };

    users = rec {
      users.${user} = {
        home = dataDir;
        createHome = true;
        inherit group;
        uid = 2004;
        isSystemUser = true;
      };
      groups.${group}.gid = users.${user}.uid;
    };

    systemd.tmpfiles.rules = [
      "d '${dataDir}' 0750 ${user} ${group} - -"
      "d '${dataDir}/config' 0750 ${user} ${group} - -"
    ];

    my.services.caddy.reverseProxyHosts = my.lib.caddy.mkReverseProxy cfg;
  };
}
