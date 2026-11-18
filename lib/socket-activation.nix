# Helpers for starting services on demand with systemd socket activation.
# For services that bind their own socket and cannot accept systemd's
# listening file descriptor directly.
{
  lib,
  options,
}: {
  # Put under my.services.<name>.socketActivation.
  mkOptions = {
    serviceName,
    defaultBackendPort,
  }: {
    enable = lib.mkEnableOption "on-demand ${serviceName} activation";
    backendPort = options.mkPortOption "${serviceName} backend" defaultBackendPort;
    idleTimeout = lib.mkOption {
      type = lib.types.str;
      default = "5min";
      description = "How long the proxy and ${serviceName} stay up without an active connection.";
    };
    startTimeout = lib.mkOption {
      type = lib.types.str;
      default = "2min";
      description = "How long to wait for ${serviceName} to start listening before failing.";
    };
  };

  # Returns a systemd attrset to merge into config. `name` is the unit basename.
  mkUnits = {
    name,
    displayName ? name,
    address,
    port,
    backendPort,
    idleTimeout,
    startTimeout,
    pkgs,
    systemdPackage,
  }: {
    services.${name} = {
      wantedBy = lib.mkForce [];
      unitConfig.StopWhenUnneeded = true;
    };

    sockets.${name} = {
      description = "On-demand ${displayName} activation";
      wantedBy = ["sockets.target"];
      listenStreams = ["${address}:${toString port}"];
      socketConfig.Service = "${name}-proxy.service";
    };

    services."${name}-proxy" = {
      description = "Forward activated ${displayName} connections to its backend";
      requires = ["${name}.service" "${name}.socket"];
      after = ["${name}.service" "${name}.socket"];
      serviceConfig = {
        # systemd-socket-proxyd drops clients whose backend connect is refused.
        # Keep them queued until the backend actually accepts connections.
        ExecStartPre = ''
          ${pkgs.bash}/bin/bash -c 'until (exec 3<>/dev/tcp/${address}/${toString backendPort}) 2>/dev/null; do sleep 1; done'
        '';
        ExecStart = lib.escapeShellArgs [
          "${systemdPackage}/lib/systemd/systemd-socket-proxyd"
          "--exit-idle-time=${idleTimeout}"
          "${address}:${toString backendPort}"
        ];
        TimeoutStartSec = startTimeout;
      };
    };
  };
}
