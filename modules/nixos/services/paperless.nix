{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.paperless;

  domain = "https://${cfg.reverseProxy.domain}";
in {
  options.my.services.paperless = let
    serviceName = "Paperless";
  in {
    enable = lib.mkEnableOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 28981;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;

    passwordFile = lib.mkOption {
      type = with lib.types; nullOr path;
      example = "/run/secrets/paperless-password";
      description = "The path to the Paperless password file.";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];

    services.paperless = {
      enable = true;
      configureNginx = false;
      database.createLocally = true;
      inherit (cfg) address port passwordFile;
      inherit domain;
      settings = {
        PAPERLESS_OCR_LANGUAGE = "pol+eng";
        PAPERLESS_TIME_ZONE = "Europe/Warsaw";
      };
    };

    my.services.caddy.reverseProxyHosts = my.lib.caddy.mkReverseProxy cfg;
  };
}
