{
  my,
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.services.comfyui;
in {
  options.my.services.comfyui = let
    serviceName = "ComfyUI";
  in {
    enable = lib.mkEnableOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 8188;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;

    modelsDir = lib.mkOption {
      type = with lib.types; nullOr path;
      default = null;
      example = "/mnt/fast_store/comfyui/models";
      description = "The directory where models are kept. When null, models live inside the state directory.";
    };

    socketActivation = {
      enable = lib.mkEnableOption "on-demand ComfyUI activation";

      backendPort = my.lib.options.mkPortOption "ComfyUI backend" 8189;

      idleTimeout = lib.mkOption {
        type = lib.types.str;
        default = "10min";
        description = "How long the proxy and ComfyUI stay up without an active connection.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.comfyui = {
      enable = true;
      port =
        if cfg.socketActivation.enable
        then cfg.socketActivation.backendPort
        else cfg.port;
      listen = [cfg.address];
      extraPackages = ps:
        with ps; [
          comfyui-manager
          markdownify # for comfyui-model-manager
        ];
      extraArgs = [
        "--disable-pinned-memory"
        "--fast-disk"
        "--vram-headroom"
        "1.5"
        "--disable-product-tips"
        "--enable-manager"
      ];
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];

    systemd = {
      tmpfiles.rules = lib.mkIf (cfg.modelsDir != null) [
        "d ${cfg.modelsDir} 0700 comfyui comfyui -"
        "d ${config.services.comfyui.dataDir}/models 0700 comfyui comfyui -"
      ];

      services.comfyui = {
        wantedBy = lib.mkIf cfg.socketActivation.enable (lib.mkForce []);
        unitConfig = lib.mkIf cfg.socketActivation.enable {
          StopWhenUnneeded = true;
        };
        preStart = lib.mkIf (cfg.modelsDir != null) (lib.mkBefore ''
          # The models directory is bind-mounted, so populate its default layout ourselves.
          # The host path is read-only inside the unit (ProtectSystem=strict); use the
          # bind-mounted view instead.
          if [ -z "$(ls -A ${config.services.comfyui.dataDir}/models)" ]; then
            cp --no-preserve=all -r ${config.services.comfyui.finalPackage}/share/comfyui/models/. ${config.services.comfyui.dataDir}/models/
            chmod -R u+rwX ${config.services.comfyui.dataDir}/models
          fi
        '');
        serviceConfig.BindPaths = lib.mkIf (cfg.modelsDir != null) [
          "${cfg.modelsDir}:${config.services.comfyui.dataDir}/models"
        ];
      };

      sockets.comfyui = lib.mkIf cfg.socketActivation.enable {
        description = "On-demand ComfyUI activation";
        wantedBy = ["sockets.target"];
        listenStreams = ["${cfg.address}:${toString cfg.port}"];
        socketConfig.Service = "comfyui-proxy.service";
      };

      services.comfyui-proxy = lib.mkIf cfg.socketActivation.enable {
        description = "Forward activated ComfyUI connections to its backend";
        requires = ["comfyui.service" "comfyui.socket"];
        after = ["comfyui.service" "comfyui.socket"];
        serviceConfig = {
          # systemd-socket-proxyd drops a client whose backend connect is refused.
          # Hold the activated connections in the socket backlog until ComfyUI is
          # actually listening, so early requests wait instead of failing.
          ExecStartPre = ''
            ${pkgs.bash}/bin/bash -c 'until (exec 3<>/dev/tcp/${cfg.address}/${toString cfg.socketActivation.backendPort}) 2>/dev/null; do sleep 1; done'
          '';
          ExecStart = lib.escapeShellArgs [
            "${config.systemd.package}/lib/systemd/systemd-socket-proxyd"
            "--exit-idle-time=${cfg.socketActivation.idleTimeout}"
            "${cfg.address}:${toString cfg.socketActivation.backendPort}"
          ];
          TimeoutStartSec = "10min";
        };
      };
    };

    my.services.caddy.reverseProxyHosts = my.lib.caddy.mkReverseProxy cfg;
  };
}
