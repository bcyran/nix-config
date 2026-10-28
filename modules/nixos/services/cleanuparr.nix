{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.cleanuparr;

  # renovate: datasource=docker packageName=ghcr.io/cleanuparr/cleanuparr
  imageVersion = "2.10.12";
  dataDir = "/var/lib/cleanuparr";
  uid = 2005;
in {
  options.my.services.cleanuparr = let
    serviceName = "Cleanuparr";
  in {
    enable = lib.mkEnableOption serviceName;
    user = my.lib.options.mkUserOption serviceName;
    group = my.lib.options.mkGroupOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 11011;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;
    environmentFiles = my.lib.options.mkEnvironmentFilesOption serviceName;
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];

      virtualisation.oci-containers.containers.cleanuparr = {
        image = "ghcr.io/cleanuparr/cleanuparr:${imageVersion}";
        autoStart = true;
        ports = [
          "${cfg.address}:${builtins.toString cfg.port}:${builtins.toString cfg.port}"
        ];
        volumes = [
          "${dataDir}/config:/config"
        ];
        environment = {
          PORT = builtins.toString cfg.port;
          PUID = toString config.users.users.${cfg.user}.uid;
          PGID = toString config.users.groups.${cfg.group}.gid;
          UMASK = "022";
          TZ = "Europe/Warsaw";
        };
        extraOptions = [
          "--userns=keep-id"
          "--cap-drop=ALL"
          "--security-opt=no-new-privileges"
        ];
        inherit (cfg) environmentFiles;
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
