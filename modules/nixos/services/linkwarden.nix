{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.linkwarden;

  linkwardenVersion = "v2.9.3";
  pgDatabase = "linkwarden";
in {
  options.my.services.linkwarden = let
    serviceName = "linkwarden";
  in {
    enable = lib.mkEnableOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 8088;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;
    dataDir = my.lib.options.mkDataDirOption serviceName "/var/lib/linkwarden";
    environmentFiles = my.lib.options.mkEnvironmentFilesOption serviceName;
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];

    services.postgresql = {
      ensureDatabases = [pgDatabase];
      ensureUsers = [
        {
          name = pgDatabase;
          ensureDBOwnership = true;
          ensureClauses.login = true;
        }
      ];
      authentication = ''
        local ${pgDatabase} ${pgDatabase} trust
      '';
    };

    virtualisation.oci-containers.containers.linkwarden = {
      image = "ghcr.io/linkwarden/linkwarden:${linkwardenVersion}";
      autoStart = true;
      ports = ["${cfg.address}:${builtins.toString cfg.port}:3000"];
      volumes = [
        "${cfg.dataDir}:/data/data"
        "/run/postgresql:/run/postgresql"
      ];
      environment = {
        NEXTAUTH_URL = "https://${cfg.reverseProxy.domain}";
        NEXT_PUBLIC_DISABLE_REGISTRATION = "true";
        LINKWARDEN_HOST = cfg.reverseProxy.domain;
        DATABASE_URL = "postgresql://${pgDatabase}@localhost/${pgDatabase}?host=/run/postgresql";
        DATABASE_PORT = "5432";
        DATABASE_NAME = pgDatabase;
        DATABASE_USER = pgDatabase;
      };
      inherit (cfg) environmentFiles;
    };

    systemd.tmpfiles.rules = [
      "d '${cfg.dataDir}' 0750 root root - -"
    ];

    my.services.caddy.reverseProxyHosts = my.lib.caddy.mkReverseProxy cfg;
  };
}
