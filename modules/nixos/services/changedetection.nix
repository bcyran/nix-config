{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.changedetection;
  playwrightCfg = config.my.services.playwright-chromium;
in {
  options.my.services.changedetection = let
    serviceName = "changedetection";
  in {
    enable = lib.mkEnableOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 8100;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;
    environmentFile = my.lib.options.mkEnvironmentFileOption serviceName;
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];

    services.changedetection-io = {
      enable = true;
      listenAddress = cfg.address;
      baseURL = cfg.address;
      inherit (cfg) port environmentFile;
    };

    # When playwright-chromium is enabled, wire it up as the CDP browser backend.
    # connect_over_cdp expects an http:// URL; playwright fetches /json/version
    # from it to obtain the actual WebSocket debugger URL at runtime.
    systemd.services.changedetection-io = lib.mkIf playwrightCfg.enable {
      after = ["playwright-chromium.service"];
      requires = ["playwright-chromium.service"];
      environment.PLAYWRIGHT_DRIVER_URL = "http://${playwrightCfg.address}:${toString playwrightCfg.port}";
    };

    my.services.caddy.reverseProxyHosts = my.lib.caddy.mkReverseProxy cfg;
  };
}
