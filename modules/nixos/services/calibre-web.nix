{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.calibre-web;
in {
  options.my.services.calibre-web = let
    serviceName = "Calibre Web";
  in {
    enable = lib.mkEnableOption serviceName;
    user = my.lib.options.mkUserOption serviceName;
    group = my.lib.options.mkGroupOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 8092;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;

    calibreLibrary = lib.mkOption {
      type = lib.types.path;
      description = "Path to the Calibre library.";
      example = "/path/to/calibre/library";
    };
  };

  config = lib.mkIf cfg.enable {
    services.calibre-web = {
      enable = true;
      listen = {
        ip = cfg.address;
        inherit (cfg) port;
      };
      inherit (cfg) user group openFirewall;
      options = {
        inherit (cfg) calibreLibrary;
      };
    };

    systemd.tmpfiles.rules = [
      "d '${cfg.calibreLibrary}' 0775 ${cfg.user} ${cfg.group} - -"
    ];

    my.services.caddy.reverseProxyHosts = my.lib.caddy.mkReverseProxy cfg;
  };
}
