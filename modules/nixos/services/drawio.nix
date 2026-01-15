{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.drawio;

  drawioVersion = "29.3.0";
in {
  options.my.services.drawio = let
    serviceName = "draw.io";
  in {
    enable = lib.mkEnableOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 8087;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];

    virtualisation.oci-containers.containers.drawio = {
      image = "jgraph/drawio:${drawioVersion}";
      autoStart = true;
      ports = ["${cfg.address}:${builtins.toString cfg.port}:8080"];
    };

    my.services.caddy.reverseProxyHosts = my.lib.caddy.mkReverseProxy cfg;
  };
}
