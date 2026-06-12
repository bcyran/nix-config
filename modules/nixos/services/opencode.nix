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
    user = my.lib.options.mkUserOption serviceName;
    group = my.lib.options.mkGroupOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 4096;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;
    environmentFile = my.lib.options.mkEnvironmentFileOption serviceName;
  };

  config = lib.mkIf cfg.enable {
    systemd = {
      tmpfiles.rules = [
        "d '${dataDir}' 0750 ${cfg.user} ${cfg.group} - -"
      ];

      services.opencode = {
        description = "opencode server";
        after = ["network.target"];
        wantedBy = ["multi-user.target"];

        serviceConfig = {
          Type = "simple";
          User = cfg.user;
          Group = cfg.group;
          WorkingDirectory = dataDir;
          ExecStart = lib.concatStringsSep " " (
            [
              (lib.getExe pkgs.opencode)
              "serve"
              "--hostname ${cfg.address}"
              "--port ${toString cfg.port}"
            ]
            ++ lib.optional (cfg.reverseProxy.domain != null) "--cors https://${cfg.reverseProxy.domain}"
          );
          Restart = "on-failure";
          EnvironmentFile = cfg.environmentFile;
        };
      };
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];

    users = {
      users = lib.mkIf (cfg.user == "opencode") {
        opencode = {
          isSystemUser = true;
          inherit (cfg) group;
          home = dataDir;
          createHome = true;
        };
      };
      groups = lib.mkIf (cfg.group == "opencode") {opencode = {};};
    };

    my.services.caddy.reverseProxyHosts = my.lib.caddy.mkReverseProxy cfg;
  };
}
