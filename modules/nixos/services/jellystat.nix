{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.jellystat;

  dbName = "jellystat";
  dbUser = "jellystat";
in {
  options.my.services.jellystat = let
    serviceName = "Jellystat";
  in {
    enable = lib.mkEnableOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 8099;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;
    environmentFiles = my.lib.options.mkEnvironmentFilesOption serviceName;
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
        local ${dbName} ${dbUser} trust
      '';
    };

    systemd.services.jellystat = {
      description = "Jellystat - Statistics App for Jellyfin";
      after = ["network.target" "postgresql.service"];
      requires = ["postgresql.service"];
      wantedBy = ["multi-user.target"];

      environment = {
        # Required
        POSTGRES_USER = dbUser;
        POSTGRES_PASSWORD = "";
        POSTGRES_IP = "localhost";
        POSTGRES_PORT = toString config.my.services.postgresql.port;
        TZ = "Europe/Warsaw";
        # JWT_SECRET is required and should be provided via env file

        # Optional
        POSTGRES_DB = dbName;
        JS_LISTEN_IP = cfg.address;
        JS_LISTEN_PORT = toString cfg.port; # This doesn't exist in upstream, we patch this in the package.
        MINIMUM_SECONDS_TO_INCLUDE_PLAYBACK = "60";
      };

      serviceConfig = {
        Type = "simple";
        ExecStart = lib.getExe my.pkgs.jellystat;
        Restart = "on-failure";
        EnvironmentFile = cfg.environmentFiles;

        DynamicUser = true;
        StateDirectory = "jellystat";

        # Hardening
        CapabilityBoundingSet = "";
        NoNewPrivileges = true;
        PrivateUsers = true;
        PrivateTmp = true;
        PrivateDevices = true;
        PrivateMounts = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
          "AF_NETLINK"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
      };
    };

    my.services.caddy.reverseProxyHosts = my.lib.caddy.mkReverseProxy cfg;
  };
}
