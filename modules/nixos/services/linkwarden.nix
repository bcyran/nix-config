{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.linkwarden;
  ollamaCfg = config.my.services.ollama;
in {
  options.my.services.linkwarden = let
    serviceName = "linkwarden";
  in {
    enable = lib.mkEnableOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 8088;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;
    environmentFile = my.lib.options.mkEnvironmentFileOption serviceName;

    llm = lib.mkOption {
      type = with lib.types; nullOr str;
      default = null;
      example = "gemma:2b";
      description = "The model to use for tags inference.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.linkwarden = {
      enable = true;
      host = cfg.address;
      inherit (cfg) port openFirewall environmentFile;
      database.createLocally = true;
      enableRegistration = false;
      environment =
        {
          NEXTAUTH_URL = "https://${cfg.reverseProxy.domain}";
          PREVIEW_MAX_BUFFER = "1";
          READABILITY_MAX_BUFFER = "10";
          SCREENSHOT_MAX_BUFFER = "10";
          MONOLITH_MAX_BUFFER = "100";
          RE_ARCHIVE_LIMIT = "0.01";
        }
        // lib.optionalAttrs (cfg.llm != null && ollamaCfg.enable) {
          NEXT_PUBLIC_OLLAMA_ENDPOINT_URL = "http://localhost:${toString ollamaCfg.port}";
          OLLAMA_MODEL = cfg.llm;
        };
    };

    my.services.caddy.reverseProxyHosts = my.lib.caddy.mkReverseProxy cfg;
  };
}
