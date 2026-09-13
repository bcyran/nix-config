{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.dawarich;
in {
  options.my.services.dawarich = let
    serviceName = "Dawarich";
  in {
    enable = lib.mkEnableOption serviceName;
    user = my.lib.options.mkUserOption serviceName;
    group = my.lib.options.mkGroupOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 8104;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;
    environmentFiles = my.lib.options.mkEnvironmentFilesOption serviceName;
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];

    services.dawarich = {
      enable = true;
      localDomain = lib.defaultTo "localhost" cfg.reverseProxy.domain;
      webPort = cfg.port;
      inherit (cfg) user group;
      extraEnvFiles = cfg.environmentFiles;
      configureNginx = false;
    };

    my.services.caddy.reverseProxyHosts = my.lib.caddy.mkReverseProxy cfg;
  };
}
