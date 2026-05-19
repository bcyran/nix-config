{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.cleanuparr;

  cleanuparrVersion = "2.9.13";
  user = "cleanuparr";
  group = "cleanuparr";
  dataDir = "/var/lib/cleanuparr";
in {
  options.my.services.cleanuparr = let
    serviceName = "Cleanuparr";
  in {
    enable = lib.mkEnableOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 11011;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;
    environmentFiles = my.lib.options.mkEnvironmentFilesOption serviceName;
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];

    virtualisation.oci-containers.containers.cleanuparr = {
      image = "ghcr.io/cleanuparr/cleanuparr:${cleanuparrVersion}";
      autoStart = true;
      ports = [
        "${cfg.address}:${builtins.toString cfg.port}:${builtins.toString cfg.port}"
      ];
      volumes = [
        "${dataDir}/config:/config"
      ];
      environment = {
        PORT = builtins.toString cfg.port;
        PUID = toString config.users.users.${user}.uid;
        PGID = toString config.users.groups.${group}.gid;
        UMASK = "022";
        TZ = "Etc/UTC";
      };
      extraOptions = [
        "--network=slirp4netns:allow_host_loopback=true"
      ];
      inherit (cfg) environmentFiles;
    };

    users = rec {
      users.${user} = {
        home = dataDir;
        createHome = true;
        inherit group;
        uid = 2005;
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
