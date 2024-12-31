{
  config,
  lib,
  ...
}: let
  cfg = config.my.services.open-webui;
  ollamaCfg = config.my.services.ollama;
in {
  options.my.services.open-webui = {
    enable = lib.mkEnableOption "Open WebUI";

    port = lib.mkOption {
      type = lib.types.int;
      default = 8084;
      description = "The port on which the Open WebUI is accessible.";
    };

    domain = lib.mkOption {
      type = lib.types.str;
      example = "open-webui.home.my.tld";
      description = "The domain on which the Open WebUI is accessible.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.open-webui = {
      enable = true;
      host = "127.0.0.1";
      inherit (cfg) port;
      openFirewall = true;
      environment = {
        OLLAMA_API_BASE_URL = "http://127.0.0.1:${toString ollamaCfg.port}";
        ENABLE_OPENAI_API = "false";
      };
    };

    my.services.reverseProxy.virtualHosts.${cfg.domain} = {
      backendAddress = "127.0.0.1";
      backendPort = cfg.port;
    };
  };
}
