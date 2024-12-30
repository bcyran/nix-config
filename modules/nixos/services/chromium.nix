{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.chromium;
in {
  options = {
    my.services.chromium = {
      enable = lib.mkEnableOption "chromium";

      internalPort = lib.mkOption {
        type = lib.types.int;
        default = 9222;
        description = "The port on which the remote debugging is accessible from the localhost.";
      };
      externalPort = lib.mkOption {
        type = lib.types.int;
        default = 9223;
        description = "The port on which the remote debugging is accessible from all interfaces.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [cfg.externalPort];

    # It's a "feature" that Chromium disallows binding to 0.0.0.0 using `--remote-debugging-address`.
    # See: https://issues.chromium.org/issues/327558594.
    # This is a workaround to forward the port so it's accessible from outside.
    systemd.services.chromium-forward = {
      description = "Forward Chromium remote debugging port from the external to the internal interface";
      wantedBy = ["multi-user.target"];
      after = ["network.target"];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.socat}/bin/socat tcp-listen:${toString cfg.externalPort},reuseaddr,fork tcp:127.0.0.1:${toString cfg.internalPort}";
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
          "--remote-debugging-port=${toString cfg.internalPort}"
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
