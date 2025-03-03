{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.jellyfin;
in {
  options.my.services.jellyfin = let
    serviceName = "jellyfin";
  in {
    enable = lib.mkEnableOption serviceName;
    user = my.lib.options.mkUserOption serviceName;
    group = my.lib.options.mkGroupOption serviceName;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;
    dataDir = my.lib.options.mkDataDirOption serviceName "/var/lib/jellyfin";
  };

  config = lib.mkIf cfg.enable {
    services.jellyfin = {
      enable = true;
      inherit (cfg) user group openFirewall dataDir;
    };

    systemd.tmpfiles.rules = [
      "d '${cfg.dataDir}'   0700 ${cfg.user} ${cfg.group} - -"
    ];

    my.services.caddy.reverseProxyHosts = lib.optionalAttrs (cfg.reverseProxy.domain != null) {
      ${cfg.reverseProxy.domain} = {
        upstreamAddress = "127.0.0.1";
        upstreamPort = 8096;
      };
    };
  };
}
