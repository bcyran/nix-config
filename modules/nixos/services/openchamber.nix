{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.openchamber;
  opencodeCfg = config.my.services.opencode;
  dataDir = "/var/lib/openchamber";
in {
  options.my.services.openchamber = let
    serviceName = "openchamber";
  in {
    enable = lib.mkEnableOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 8102;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;
    environmentFile = my.lib.options.mkEnvironmentFileOption serviceName;

    workingDirectory = lib.mkOption {
      type = lib.types.path;
      example = "/srv/repos";
      description = "Working directory for the openchamber server. The path will be bind-mounted read-write into the service's namespace.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = opencodeCfg.enable;
        message = "my.services.openchamber requires my.services.opencode to be enabled.";
      }
      # Seriously, OpenChamber doesn't support opencode authentication at all.
      # This means that OpenCode needs to run without password so it can't be exposed through reverse proxy.
      # See: https://github.com/openchamber/openchamber/issues/1417.
      {
        assertion = opencodeCfg.reverseProxy.domain == null;
        message = "my.services.opencode must not have a reverse proxy configured when used with my.services.openchamber, as openchamber does not support opencode authentication.";
      }
    ];

    systemd.services.openchamber = {
      description = "openchamber server";
      after = ["network.target" "opencode.service"];
      requires = ["opencode.service"];
      wantedBy = ["multi-user.target"];

      environment = {
        HOME = dataDir;
        OPENCHAMBER_HOST = cfg.address;
        OPENCHAMBER_DATA_DIR = dataDir;
        OPENCODE_HOST = "http://${opencodeCfg.address}:${toString opencodeCfg.port}";
        OPENCODE_SKIP_START = "true";
      };

      serviceConfig = {
        Type = "simple";
        ExecStart = "${lib.getExe my.pkgs.openchamber} --foreground --port ${toString cfg.port}";
        Restart = "on-failure";

        # Dynamic user
        DynamicUser = true;
        StateDirectory = "openchamber";

        # Hardening
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = "tmpfs";
        NoNewPrivileges = true;
        PrivateDevices = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        RestrictNamespaces = true;
        LockPersonality = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        WorkingDirectory = cfg.workingDirectory;
        BindPaths = [cfg.workingDirectory];
        EnvironmentFile = cfg.environmentFile;
      };
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];

    my.services.caddy.reverseProxyHosts = my.lib.caddy.mkReverseProxy cfg;
  };
}
