{
  pkgs,
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.forgejo-mcp;
  forgejoCfg = config.my.services.forgejo;
in {
  options.my.services.forgejo-mcp = let
    serviceName = "forgejo-mcp";
  in {
    enable = lib.mkEnableOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 8083;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;
    forgejoUrl = lib.mkOption {
      type = lib.types.str;
      default = "http://${forgejoCfg.address}:${toString forgejoCfg.port}";
      defaultText =
        lib.literalExpression
        ''"http://${config.my.services.forgejo.address}:${toString config.my.services.forgejo.port}"'';
      example = "http://127.0.0.1:8085";
      description = "URL of the Forgejo instance the MCP server connects to.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = forgejoCfg.enable;
        message = "my.services.forgejo-mcp requires my.services.forgejo to be enabled.";
      }
    ];

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];

    systemd.services.forgejo-mcp = {
      description = "Forgejo MCP server";
      after = ["network.target" "forgejo.service"];
      wants = ["forgejo.service"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        Type = "simple";
        ExecStart = lib.concatStringsSep " " (
          [
            (lib.getExe pkgs.forgejo-mcp)
            "--transport http"
            "--host ${cfg.address}"
            "--http-port ${toString cfg.port}"
            "--url ${cfg.forgejoUrl}"
          ]
          # The server rejects non-loopback Host headers unless allowed;
          # Caddy forwards the public domain, so it must be added there.
          ++ lib.optional (cfg.reverseProxy.domain != null) "--allowed-hosts ${cfg.reverseProxy.domain}"
        );
        Restart = "on-failure";
        DynamicUser = true;

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
      };
    };

    my.services.caddy.reverseProxyHosts = my.lib.caddy.mkReverseProxy cfg;
  };
}
