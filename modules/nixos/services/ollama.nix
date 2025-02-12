{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.ollama;
in {
  options.my.services.ollama = let
    serviceName = "Ollama";
  in {
    enable = lib.mkEnableOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 11434;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;
  };

  config = lib.mkIf cfg.enable {
    services.ollama = {
      enable = true;
      host = cfg.address;
      inherit (cfg) port openFirewall;
    };

    my.services.caddy.reverseProxyHosts = my.lib.caddy.mkReverseProxy cfg;
  };
}
