{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.tandoor;
in {
  options.my.services.tandoor = let
    serviceName = "Tandoor";
  in {
    enable = lib.mkEnableOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 8103;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;
    environmentFiles = my.lib.options.mkEnvironmentFilesOption serviceName;
  };

  config = lib.mkIf cfg.enable {
    services.tandoor-recipes = {
      enable = true;
      inherit (cfg) address port;
      database.createLocally = true;
      extraConfig = {
        ALLOWED_HOSTS = lib.concatStringsSep "," [cfg.reverseProxy.domain "127.0.0.1"];
        MEDIA_ROOT = "/var/lib/tandoor-recipes/media";
        GUNICORN_MEDIA = true; # Serve /media/ through gunicorn.
      };
    };

    systemd.services.tandoor-recipes.serviceConfig.EnvironmentFile = cfg.environmentFiles;

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];

    my.services.caddy.reverseProxyHosts = my.lib.caddy.mkReverseProxy cfg;
  };
}
