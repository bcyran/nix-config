{
  my,
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.openchamber;
  opencodeCfg = config.my.services.opencode;
  dataDir = "/var/lib/openchamber";

  gitconfig = pkgs.writeText "openchamber-gitconfig" (lib.generators.toINI {} {
    core = {
      sshCommand = "ssh -i ${cfg.git.sshKeyFile} -o StrictHostKeyChecking=accept-new -o IdentitiesOnly=yes";
      sharedRepository = "group";
    };
    safe = {
      directory = "*";
    };
    user = {
      name = cfg.git.userName;
      email = cfg.git.userEmail;
    };
  });
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
    user = my.lib.options.mkUserOption serviceName;
    group = my.lib.options.mkGroupOption serviceName;

    workingDirectory = lib.mkOption {
      type = lib.types.path;
      example = "/srv/repos";
      description = "Working directory for the openchamber server. The path will be made read-write accessible inside the service's namespace.";
    };

    git = {
      sshKeyFile = lib.mkOption {
        type = lib.types.path;
        example = "/var/lib/opencode/.ssh/id_ed25519";
        description = "SSH private key for git push operations.";
      };

      userName = lib.mkOption {
        type = lib.types.str;
        example = "openchamber Agent";
        description = "Git user name for commits made by the service.";
      };

      userEmail = lib.mkOption {
        type = lib.types.str;
        example = "agent@openchamber.local";
        description = "Git user email for commits made by the service.";
      };
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

    systemd.tmpfiles.rules = [
      "L+ ${dataDir}/.gitconfig 0644 ${cfg.user} ${cfg.group} - ${gitconfig}"
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
        EnvironmentFile = cfg.environmentFile;
        Restart = "on-failure";

        User = cfg.user;
        Group = cfg.group;
        StateDirectory = "openchamber";
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
