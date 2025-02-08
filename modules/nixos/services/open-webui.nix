{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.open-webui;
  ollamaCfg = config.my.services.ollama;
in {
  options.my.services.open-webui = let
    serviceName = "Open WebUI";
  in {
    enable = lib.mkEnableOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 8084;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    domain = my.lib.options.mkDomainOption serviceName;
  };

  config = lib.mkIf cfg.enable {
    services.open-webui = {
      enable = true;
      host = cfg.address;
      inherit (cfg) port openFirewall;
      environment = {
        OLLAMA_API_BASE_URL = "http://127.0.0.1:${toString ollamaCfg.port}";
        ENABLE_OPENAI_API = "false";
      };
    };

    services.caddy.virtualHosts = my.lib.caddy.makeReverseProxy {
      inherit (cfg) domain address port;
    };
  };
}
