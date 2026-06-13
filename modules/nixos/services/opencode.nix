{
  pkgs,
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.opencode;
  dataDir = "/var/lib/opencode";

  gitconfig = pkgs.writeText "opencode-gitconfig" (lib.generators.toINI {} {
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

    git = {
      sshKeyFile = lib.mkOption {
        type = lib.types.path;
        example = "/var/lib/opencode/.ssh/id_ed25519";
        description = "SSH private key for git push operations.";
      };

      userName = lib.mkOption {
        type = lib.types.str;
        example = "opencode Agent";
        description = "Git user name for commits made by the service.";
      };

      userEmail = lib.mkOption {
        type = lib.types.str;
        example = "agent@opencode.local";
        description = "Git user email for commits made by the service.";
      };
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

    systemd.tmpfiles.rules = [
      "L+ ${dataDir}/.gitconfig 0644 ${cfg.user} ${cfg.group} - ${gitconfig}"
    ];

    systemd.services.opencode = {
      description = "opencode server";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];

      environment = {
        HOME = dataDir;
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
