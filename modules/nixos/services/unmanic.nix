{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.unmanic;

  cacheDir = "/var/cache/unmanic";
  unmanicVersion = "0.2.7";
in {
  options.my.services.unmanic = let
    serviceName = "Unmanic";
  in {
    enable = lib.mkEnableOption serviceName;
    user = my.lib.options.mkUserOption serviceName;
    group = my.lib.options.mkGroupOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 8888;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;
    dataDir = my.lib.options.mkDataDirOption serviceName "/var/lib/unmanic";

    mediaDir = lib.mkOption {
      type = lib.types.path;
      example = "/path/to/media";
      description = "The path to the media library directory.";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];

    virtualisation.oci-containers.containers.unmanic = {
      image = "josh5/unmanic:${unmanicVersion}";
      autoStart = true;
      ports = [
        "${cfg.address}:${builtins.toString cfg.port}:8888"
      ];
      volumes = [
        "${cfg.dataDir}:/config"
        "${cfg.mediaDir}:/library"
        "${cacheDir}:/tmp/unmanic"
      ];
      devices = [
        "/dev/dri:/dev/dri"
      ];
      environment = {
        PUID = toString config.users.users.${cfg.user}.uid;
        PGID = toString config.users.groups.${cfg.group}.gid;
      };
    };

    users = {
      users = lib.mkIf (cfg.user == "unmanic") {
        unmanic = {
          name = "unmanic";
          isSystemUser = true;
          uid = 2003;
          inherit (cfg) group;
        };
        groups = lib.mkIf (cfg.group == "unmanic") {unmanic.gid = 2003;};
      };
    };

    systemd.tmpfiles.rules = [
      "d '${cfg.dataDir}'   0700 ${cfg.user} ${cfg.group} - -"
      "d '${cacheDir}'      0700 ${cfg.user} ${cfg.group} - -"
    ];

    my.services.caddy.reverseProxyHosts = my.lib.caddy.mkReverseProxy cfg;
  };
}
