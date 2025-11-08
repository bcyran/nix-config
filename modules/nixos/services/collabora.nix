{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.collabora;
in {
  options.my.services.collabora = let
    serviceName = "Collabora CODE";
  in {
    enable = lib.mkEnableOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 9980;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;
    environmentFiles = my.lib.options.mkEnvironmentFilesOption serviceName;
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];

    services.collabora-online = {
      enable = true;
      inherit (cfg) port;

      aliasGroups = [
        {host = config.my.services.nextcloud.domain;}
      ];

      settings = {
        ssl = {
          enable = false;
          termination = true;
        };
        net = {
          listen = cfg.address;
          post_allow.host = ["::1"];
        };
        storage.wopi = {
          "@allow" = true;
          host = [config.my.services.nextcloud.domain];
        };
        server_name = cfg.reverseProxy.domain;
        allowed_languages = "pl_PL en_US";
      };
    };
    systemd.services.coolwsd.serviceConfig.EnvironmentFile = cfg.environmentFiles;

    my.services.caddy.reverseProxyHosts = my.lib.caddy.mkReverseProxy cfg;
  };
}
