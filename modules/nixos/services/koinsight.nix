{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.koinsight;
in {
  options.my.services.koinsight = let
    serviceName = "KoInsight";
  in {
    enable = lib.mkEnableOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 8093;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];

    systemd.services.koinsight = {
      description = "KOReader reading stats service";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];

      environment = {
        DATA_PATH = "/var/lib/koinsight";
        HOSTNAME = cfg.address;
        PORT = toString cfg.port;
        MAX_FILE_SIZE_MB = "100";
      };

      serviceConfig = {
        Type = "simple";
        ExecStart = lib.getExe my.pkgs.koinsight;
        Restart = "on-failure";

        DynamicUser = true;
        StateDirectory = "koinsight";

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
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
      };
    };

    my.services.caddy.reverseProxyHosts = my.lib.caddy.mkReverseProxy cfg;
  };
}
