{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.edo-calculator;

  edoCalculatorVersion = "sha-85b6167";
in {
  options.my.services.edo-calculator = let
    serviceName = "EDO Calculator";
  in {
    enable = lib.mkEnableOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 8097;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];

    virtualisation.oci-containers.containers.edo-calculator = {
      image = "ghcr.io/krbob/edo-calculator:${edoCalculatorVersion}";
      autoStart = true;
      ports = ["${cfg.address}:${builtins.toString cfg.port}:8080"];
    };

    my.services.caddy.reverseProxyHosts = my.lib.caddy.mkReverseProxy cfg;
  };
}
