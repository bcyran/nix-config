{
  my,
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.services.ntfy;
in {
  options.my.services.ntfy = let
    serviceName = "ntfy";
  in {
    enable = lib.mkEnableOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 2586;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    domain = my.lib.options.mkDomainOption serviceName;
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];

    services.ntfy-sh = {
      enable = true;
      settings = {
        listen-http = "${cfg.address}:${toString cfg.port}";
        base-url = "https://${cfg.domain}";
        behind-proxy = true;
      };
    };

    systemd.services."ntfy-failed@" = {
      description = "Send ntfy notification about %i failure";
      scriptArgs = "%i";
      script = ''
        ${pkgs.curl}/bin/curl \
          -H "Title: Systemd: unit failed" \
          -H "Tags: warning" \
          -d "Unit: $1.service" \
          http://127.0.0.1:${toString cfg.port}/systemd
      '';
    };

    my.reverseProxy.virtualHosts.${cfg.domain} = lib.mkIf (cfg.domain != null) {
      backendAddress = cfg.address;
      backendPort = cfg.port;
    };
  };
}
