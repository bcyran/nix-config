{
  my,
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.services.playwright-chromium;

  # Run the playwright-bundled chromium-headless-shell binary directly so that
  # we expose a real Chrome DevTools Protocol endpoint via --remote-debugging-port.
  # This is required by connect_over_cdp clients (e.g. changedetection.io).
  # Using playwright's launchServer() would expose playwright's own multiplexing
  # protocol instead of CDP, which is incompatible with connect_over_cdp.
  chromiumBin = "${pkgs.playwright-driver.passthru.components.chromium-headless-shell}/chrome-headless-shell-linux64/chrome-headless-shell";
in {
  options.my.services.playwright-chromium = let
    serviceName = "Playwright Chromium";
  in {
    enable = lib.mkEnableOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 8101;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;
  };

  config = lib.mkIf cfg.enable {
    systemd.services.playwright-chromium = {
      description = "Playwright Chromium Browser Server";
      wantedBy = ["multi-user.target"];
      after = ["network.target"];

      serviceConfig = {
        # Expose CDP at http://address:port  – clients use connect_over_cdp().
        # User-data-dir is placed inside the transient RuntimeDirectory so it is
        # wiped on every restart, avoiding stale lock files.
        ExecStart = lib.concatStringsSep " " [
          chromiumBin
          "--remote-debugging-address=${cfg.address}"
          "--remote-debugging-port=${toString cfg.port}"
          "--user-data-dir=/run/playwright-chromium"
          "--disable-dev-shm-usage"
        ];

        DynamicUser = true;
        Restart = "on-failure";
        RestartSec = "5s";

        RuntimeDirectory = "playwright-chromium";
        RuntimeDirectoryMode = "0750";

        # Security hardening
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
      };
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];

    my.services.caddy.reverseProxyHosts = my.lib.caddy.mkReverseProxy cfg;
  };
}
