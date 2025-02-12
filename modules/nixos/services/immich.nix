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
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;
    dataDir = my.lib.options.mkDataDirOption serviceName "/var/lib/immich";
  };

  config = lib.mkIf cfg.enable {
    services.immich = {
      enable = true;
      host = cfg.address;
      mediaLocation = cfg.dataDir;
      inherit (cfg) port openFirewall;
      settings = {
        newVersionCheck.enabled = false;
      };
    };

    systemd.tmpfiles.rules = [
      "d '${cfg.dataDir}' 0750 ${config.services.immich.user} ${config.services.immich.group} - -"
    ];

    my.services.caddy.reverseProxyHosts = my.lib.caddy.mkReverseProxy cfg;
  };
}
