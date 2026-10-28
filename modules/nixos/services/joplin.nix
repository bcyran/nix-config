{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.joplin;
  postgresCfg = config.my.services.postgresql;

  # renovate: datasource=docker packageName=docker.io/joplin/server
  imageVersion = "3.7.3";
  dbName = "joplin";
  dbUser = "joplin";
  postgresHostAlias = "postgres";
  dataDir = "/var/lib/joplin";
  uid = 2007;
in {
  options.my.services.joplin = let
    serviceName = "Joplin";
  in {
    enable = lib.mkEnableOption serviceName;
    user = my.lib.options.mkUserOption serviceName;
    group = my.lib.options.mkGroupOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 22300;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;
    allowedLoopbackPorts = my.lib.options.mkAllowedLoopbackPortsOption serviceName;
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];

      services.postgresql = {
        ensureDatabases = [dbName];
        ensureUsers = [
          {
            name = dbUser;
            ensureDBOwnership = true;
            ensureClauses.login = true;
          }
        ];
        authentication = ''
          host ${dbName} ${dbUser} 127.0.0.1/32 trust
        '';
      };

      virtualisation.oci-containers.containers.joplin = {
        image = "docker.io/joplin/server:${imageVersion}";
        autoStart = true;
        ports = ["${cfg.address}:${toString cfg.port}:${toString cfg.port}"];
        environment = {
          DB_CLIENT = "pg";
          # Joplin replaces "localhost" and "127.0.0.1" with host.docker.internal,
          # which does not reach the forwarded port. Use an alias for 127.0.0.1
          # instead. Other loopback addresses do not work because pasta
          # connects to the same address on the host.
          POSTGRES_HOST = postgresHostAlias;
          POSTGRES_PORT = toString postgresCfg.port;
          POSTGRES_DATABASE = dbName;
          POSTGRES_USER = dbUser;
          APP_BASE_URL = "https://${cfg.reverseProxy.domain}";
          APP_PORT = toString cfg.port;
        };
        extraOptions =
          my.lib.ociContainers.mkLoopbackNetworkOptions cfg.allowedLoopbackPorts
          ++ [
            "--add-host=${postgresHostAlias}:127.0.0.1"
            "--cap-drop=ALL"
            "--security-opt=no-new-privileges"
          ];
        podman.user = cfg.user;
      };

      my.services.caddy.reverseProxyHosts = my.lib.caddy.mkReverseProxy cfg;
    }

    (my.lib.ociContainers.mkRootlessPodmanUser {
      inherit (cfg) user group;
      home = dataDir;
      inherit uid;
    })
  ]);
}
