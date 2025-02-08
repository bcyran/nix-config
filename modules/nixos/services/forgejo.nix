{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.forgejo;
in {
  options.my.services.forgejo = let
    serviceName = "Forgejo git server";
  in {
    enable = lib.mkEnableOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 8085;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    domain = my.lib.options.mkDomainOption serviceName;
    dataDir = my.lib.options.mkDataDirOption serviceName "/var/lib/forgejo";
  };

  config = lib.mkIf cfg.enable {
    services.forgejo = {
      enable = true;
      stateDir = cfg.dataDir;

      settings = {
        server = {
          HTTP_ADDR = cfg.address;
          HTTP_PORT = cfg.port;
          DOMAIN = cfg.domain;
          ROOT_URL = "https://${cfg.domain}";
        };
        actions = {
          ENABLED = false;
        };
        service = {
          DISABLE_REGISTRATION = true;
        };
      };

      dump = {
        enable = true;
        type = "tar.zst";
      };
    };

    services.caddy.virtualHosts = my.lib.caddy.makeReverseProxy {
      inherit (cfg) domain address port;
    };
  };
}
