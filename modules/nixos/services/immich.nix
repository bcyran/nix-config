{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.immich;
in {
  options.my.services.immich = let
    serviceName = "Immich";
  in {
    enable = lib.mkEnableOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 2283;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    domain = my.lib.options.mkDomainOption serviceName;
  };

  config = lib.mkIf cfg.enable {
    services.immich = {
      enable = true;
      host = cfg.address;
      inherit (cfg) port openFirewall;
      settings = {
        newVersionCheck.enabled = false;
      };
    };

    my.reverseProxy.virtualHosts.${cfg.domain} = lib.mkIf (cfg.domain != null) {
      backendAddress = cfg.address;
      backendPort = cfg.port;
    };
  };
}
