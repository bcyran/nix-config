{
  pkgs,
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.opencode;
in {
  options.my.services.opencode = let
    serviceName = "opencode";
  in {
    enable = lib.mkEnableOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 4096;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;
    environmentFile = my.lib.options.mkEnvironmentFileOption serviceName;

    workingDirectory = lib.mkOption {
      type = lib.types.path;
      example = "/srv/repos/myapp";
      description = "Working directory for the opencode server. The path will be bind-mounted read-write into the service's namespace.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.opencode = {
      description = "opencode server";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        Type = "simple";
        ExecStart = lib.concatStringsSep " " (
          [
            (lib.getExe pkgs.opencode)
            "serve"
            "--hostname ${cfg.address}"
            "--port ${toString cfg.port}"
          ]
          ++ lib.optional (cfg.reverseProxy.domain != null) "--cors https://${cfg.reverseProxy.domain}"
        );
        EnvironmentFile = cfg.environmentFile;
        Restart = "on-failure";

        # Dynamic user
        DynamicUser = true;
        StateDirectory = "opencode";
        Environment = "HOME=/var/lib/opencode";

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
      };
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];

    my.services.caddy.reverseProxyHosts = my.lib.caddy.mkReverseProxy cfg;
  };
}
