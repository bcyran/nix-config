{
  my,
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.services.forgejo;

  dumpKeepDays = 7;
in {
  options.my.services.forgejo = let
    serviceName = "Forgejo git server";
  in {
    enable = lib.mkEnableOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 8085;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;
  };

  config = lib.mkIf cfg.enable {
    services.forgejo = {
      enable = true;

      database = {
        type = "postgres";
        name = "forgejo";
        user = "forgejo";
      };

      settings = {
        server = {
          HTTP_ADDR = cfg.address;
          HTTP_PORT = cfg.port;
          DOMAIN = cfg.reverseProxy.domain;
          ROOT_URL = "https://${cfg.reverseProxy.domain}";
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
        interval = "00:05";
      };
    };

    systemd = {
      services.forgejo-dump-cleanup = {
        description = "Cleanup Forgejo dumps";
        serviceConfig = {
          Type = "oneshot";
          User = config.services.forgejo.user;
          ExecStart = let
            findBin = "${pkgs.findutils}/bin/find";
            dumpDir = config.services.forgejo.dump.backupDir;
          in "${findBin} '${dumpDir}' -type f -mtime +${builtins.toString dumpKeepDays} -delete";
        };

        startAt = "00:10";
      };
    };

    my.services.caddy.reverseProxyHosts = my.lib.caddy.mkReverseProxy cfg;
  };
}
