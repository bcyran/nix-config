{
  pkgs,
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.opencode;
  dataDir = "/var/lib/opencode";
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
    user = my.lib.options.mkUserOption serviceName;
    group = my.lib.options.mkGroupOption serviceName;

    workingDirectory = lib.mkOption {
      type = lib.types.path;
      example = "/srv/repos/myapp";
      description = "Working directory for the opencode server. The path will be made read-write accessible inside the service's namespace.";
    };
  };

  config = lib.mkIf cfg.enable {
    users = {
      users.${cfg.user} = {
        home = dataDir;
        createHome = true;
        inherit (cfg) group;
        isSystemUser = true;
        # Tools spawned by the service need a real shell; nologin (isSystemUser
        # default) causes "This account is currently not available." errors.
        shell = pkgs.bash;
      };
      groups.${cfg.group} = {};
    };

    systemd.services.opencode = {
      description = "opencode server";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];

      environment = {
        HOME = dataDir;
        # The working directory repos may be owned by a different user.
        # Git 2.35.2+ rejects repos whose owner doesn't match the calling user.
        # The service is already sandboxed (ProtectSystem=strict,
        # ReadWritePaths limited to workingDirectory), so * is safe here.
        GIT_CONFIG_COUNT = "2";
        GIT_CONFIG_KEY_0 = "safe.directory";
        GIT_CONFIG_VALUE_0 = "*";
        GIT_CONFIG_KEY_1 = "core.sharedRepository";
        GIT_CONFIG_VALUE_1 = "group";
      };

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

        User = cfg.user;
        Group = cfg.group;
        StateDirectory = "opencode";
        UMask = "0002";

        # Hardening
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
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
        ReadWritePaths = [cfg.workingDirectory];
      };
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];

    my.services.caddy.reverseProxyHosts = my.lib.caddy.mkReverseProxy cfg;
  };
}
