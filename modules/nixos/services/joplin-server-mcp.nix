{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.joplin-server-mcp;
  joplinCfg = config.my.services.joplin;
  joplinService = "${config.virtualisation.oci-containers.containers.joplin.serviceName}.service";
in {
  options.my.services.joplin-server-mcp = let
    serviceName = "Joplin Server MCP";
  in {
    enable = lib.mkEnableOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 8107;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;
    joplinUrl = lib.mkOption {
      type = lib.types.str;
      default = "https://${joplinCfg.reverseProxy.domain}";
      defaultText = lib.literalExpression ''"https://${config.my.services.joplin.reverseProxy.domain}"'';
      example = "https://joplin.example.com";
      description = ''
        URL of the Joplin Server the MCP server connects to. Joplin validates
        the request origin against APP_BASE_URL, so this must match the domain
        configured for my.services.joplin.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = joplinCfg.enable;
        message = "my.services.joplin-server-mcp requires my.services.joplin to be enabled.";
      }
    ];

    systemd.services.joplin-server-mcp = {
      description = "MCP server for Joplin Server";
      after = ["network.target" joplinService];
      wants = [joplinService];
      wantedBy = ["multi-user.target"];

      environment = {
        JOPLIN_SERVER_URL = cfg.joplinUrl;
        JOPLIN_MULTI_USER = "1";
        MCP_TRANSPORT = "streamable-http";
        MCP_HOST = cfg.address;
        MCP_PORT = toString cfg.port;
      };

      serviceConfig = {
        Type = "simple";
        ExecStart = lib.getExe my.pkgs.joplin-server-mcp;
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
