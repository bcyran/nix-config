{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.open-webui;
  llamaSwapCfg = config.my.services.llama-swap;
in {
  options.my.services.open-webui = let
    serviceName = "Open WebUI";
  in {
    enable = lib.mkEnableOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 8084;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = llamaSwapCfg.enable;
        message = "my.services.open-webui requires my.services.llama-swap to be enabled.";
      }
    ];

    services.open-webui = {
      enable = true;
      host = cfg.address;
      inherit (cfg) port openFirewall;
      environment = {
        ENABLE_OLLAMA_API = "false";
        ENABLE_OPENAI_API = "true";
        OPENAI_API_BASE_URL = "http://${llamaSwapCfg.address}:${toString llamaSwapCfg.port}/v1";
        OPENAI_API_KEY = "none";
      };
    };

    my.services.caddy.reverseProxyHosts = my.lib.caddy.mkReverseProxy cfg;
  };
}
