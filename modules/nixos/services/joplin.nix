{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.joplin;
  postgresCfg = config.my.services.postgresql;

  joplinVersion = "3.4.1";
  dbName = "joplin";
  dbUser = "joplin";
in {
  options.my.services.joplin = let
    serviceName = "Joplin";
  in {
    enable = lib.mkEnableOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 22300;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;
  };

  config = lib.mkIf cfg.enable {
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
      image = "joplin/server:${joplinVersion}";
      autoStart = true;
      ports = ["${cfg.address}:${toString cfg.port}:${toString cfg.port}"];
      environment = {
        DB_CLIENT = "pg";
        POSTGRES_HOST = "10.0.2.2";
        POSTGRES_PORT = toString postgresCfg.port;
        POSTGRES_DATABASE = dbName;
        POSTGRES_USER = dbUser;
        APP_BASE_URL = "https://${cfg.reverseProxy.domain}";
        APP_PORT = toString cfg.port;
      };
      extraOptions = [
        # Expose host's loopback interface in the container as 10.0.2.2.
        # This is needed for PostgreSQL access because it seems that Joplin
        # cannot connect via unix socket.
        "--network=slirp4netns:allow_host_loopback=true"
      ];
    };

    my.services.caddy.reverseProxyHosts = my.lib.caddy.mkReverseProxy cfg;
  };
}
