{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.glances;
in {
  options = {
    my.services.glances = let
      serviceName = "Glances";
    in {
      enable = lib.mkEnableOption serviceName;
      address = my.lib.options.mkAddressOption serviceName;
      port = my.lib.options.mkPortOption serviceName 61208;
      openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
      domain = my.lib.options.mkDomainOption serviceName;
    };
  };

  config = lib.mkIf cfg.enable {
    services.glances = {
      enable = true;
      inherit (cfg) port openFirewall;
      extraArgs = ["-B=${cfg.address}" "--webserver"];
    };

    my.services.reverseProxy.virtualHosts.${cfg.domain} = lib.mkIf (cfg.domain != null) {
      backendAddress = "127.0.0.1";
      backendPort = cfg.port;
    };
  };
}
