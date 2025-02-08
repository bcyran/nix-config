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
    domain = my.lib.options.mkDomainOption serviceName;
  };

  config = lib.mkIf cfg.enable {
    services.ollama = {
      enable = true;
      host = cfg.address;
      inherit (cfg) port openFirewall;
    };

    services.caddy.virtualHosts = my.lib.caddy.makeReverseProxy {
      inherit (cfg) domain address port;
    };
  };
}
