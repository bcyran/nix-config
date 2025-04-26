{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.linkwarden;
  ollamaCfg = config.my.services.ollama;

  linkwardenVersion = "v2.10.0";
  pgDatabase = "linkwarden";
  dataDir = "/var/lib/linkwarden";
in {
  options.my.services.linkwarden = let
    serviceName = "linkwarden";
  in {
    enable = lib.mkEnableOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 8088;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;
    environmentFiles = my.lib.options.mkEnvironmentFilesOption serviceName;

    llm = lib.mkOption {
      type = with lib.types; nullOr str;
      default = null;
      example = "gemma:2b";
      description = "The model to use for tags inference.";
    };
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
        "${dataDir}:/data/data"
        "/run/postgresql:/run/postgresql"
      ];
      environment = let
        loopback = "10.0.2.2";
      in
        {
          NEXTAUTH_URL = "https://${cfg.reverseProxy.domain}";
          NEXT_PUBLIC_DISABLE_REGISTRATION = "true";
          LINKWARDEN_HOST = cfg.reverseProxy.domain;
          DATABASE_URL = "postgresql://${pgDatabase}@localhost/${pgDatabase}?host=/run/postgresql";
          DATABASE_PORT = "5432";
          DATABASE_NAME = pgDatabase;
          DATABASE_USER = pgDatabase;
          PREVIEW_MAX_BUFFER = "1";
          READABILITY_MAX_BUFFER = "10";
          SCREENSHOT_MAX_BUFFER = "10";
          MONOLITH_MAX_BUFFER = "100";
          RE_ARCHIVE_LIMIT = "0.01";
        }
        // lib.optionalAttrs (cfg.llm != null && ollamaCfg.enable) {
          NEXT_PUBLIC_OLLAMA_ENDPOINT_URL = "http://${loopback}:${toString ollamaCfg.port}";
          OLLAMA_MODEL = cfg.llm;
        };
      extraOptions = [
        # Expose host's loopback interface in the container as 10.0.2.2.
        "--network=slirp4netns:allow_host_loopback=true"
      ];
      inherit (cfg) environmentFiles;
    };

    systemd.tmpfiles.rules = [
      "d '${dataDir}' 0750 root root - -"
    ];

    my.services.caddy.reverseProxyHosts = my.lib.caddy.mkReverseProxy cfg;
  };
}
