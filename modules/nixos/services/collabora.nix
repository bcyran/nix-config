{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.collabora;

  codeVersion = "25.04.2.1.1";
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

    virtualisation.oci-containers.containers.collabora = {
      image = "collabora/code:${codeVersion}";
      autoStart = true;
      ports = ["${cfg.address}:${builtins.toString cfg.port}:9980"];
      environment = {
        aliasgroup1 = config.my.services.nextcloud.domain;
        server_name = cfg.reverseProxy.domain;
        extra_params = "--o:ssl.enable=false --o:ssl.termination=true";
        dictionaries = "pl_PL en_US";
      };
      inherit (cfg) environmentFiles;
    };

    my.services.caddy.reverseProxyHosts = my.lib.caddy.mkReverseProxy cfg;
  };
}
