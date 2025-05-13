{
  my,
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.chromium;

  internalPort = 9223;
in {
  options.my.services.chromium = let
    serviceName = "Chromium headless";
  in {
    enable = lib.mkEnableOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 9222;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
  };

  config = let
    shouldPortFoward = cfg.address != "127.0.0.1";
    bindPort =
      if shouldPortFoward
      then internalPort
      else cfg.port;
  in
    lib.mkIf cfg.enable {
      networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];

      # It's a "feature" that Chromium disallows binding to 0.0.0.0 using `--remote-debugging-address`.
      # See: https://issues.chromium.org/issues/327558594.
      # This is a workaround: if we want to bind to something different than 127.0.0.1,
      # we'll use socat to forward the port.
      systemd.services.chromium-forward = lib.mkIf shouldPortFoward {
        description = "Forward Chromium remote debugging port from the external to the internal interface";
        wantedBy = ["multi-user.target"];
        after = ["network.target"];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.socat}/bin/socat tcp-listen:${toString cfg.port},reuseaddr,fork,bind=${cfg.address} tcp:127.0.0.1:${toString internalPort}";
        };
      };

      systemd.services.chromium = {
        description = "Headless Chromium remote debugging session";
        wantedBy = ["multi-user.target"];
        after = ["chromium-forward.service"];
        serviceConfig = {
          Type = "simple";
          ExecStart = lib.concatStringsSep " " [
            "${pkgs.chromium}/bin/chromium"
            "--headless"
            "--no-sandbox"
            "--disable-gpu"
            "--disable-dev-shm-usage"
            "--remote-debugging-port=${toString bindPort}"
            "--hide-scrollbars"
          ];
          DynamicUser = true;
          User = "chromium";
          Group = "chromium";
        };
        environment = {
          HOME = "/tmp";
          DISPLAY = ":0";
        };
      };

      users = rec {
        users.chromium = {
          group = "chromium";
          uid = 2000;
          isSystemUser = true;
        };
        groups.chromium.gid = users.chromium.uid;
      };
    };
}
