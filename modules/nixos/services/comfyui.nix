{
  my,
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.services.comfyui;
  sa = cfg.socketActivation;
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

    socketActivation = my.lib.socketActivation.mkOptions {
      inherit serviceName;
      defaultBackendPort = 8189;
    };
  };

  config = lib.mkIf cfg.enable {
    services.comfyui = {
      enable = true;
      port =
        if sa.enable
        then sa.backendPort
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

    systemd = lib.mkMerge [
      (lib.mkIf (cfg.modelsDir != null) {
        tmpfiles.rules = [
          "d ${cfg.modelsDir} 0700 comfyui comfyui -"
          "d ${config.services.comfyui.dataDir}/models 0700 comfyui comfyui -"
        ];
        services.comfyui = {
          preStart = lib.mkBefore ''
            # The models directory is bind-mounted, so populate its default layout ourselves.
            # The host path is read-only inside the unit (ProtectSystem=strict); use the
            # bind-mounted view instead.
            if [ -z "$(ls -A ${config.services.comfyui.dataDir}/models)" ]; then
              cp --no-preserve=all -r ${config.services.comfyui.finalPackage}/share/comfyui/models/. ${config.services.comfyui.dataDir}/models/
              chmod -R u+rwX ${config.services.comfyui.dataDir}/models
            fi
          '';
          serviceConfig.BindPaths = [
            "${cfg.modelsDir}:${config.services.comfyui.dataDir}/models"
          ];
        };
      })
      (lib.mkIf sa.enable (my.lib.socketActivation.mkUnits {
        name = "comfyui";
        displayName = "ComfyUI";
        inherit pkgs;
        inherit (cfg) address port;
        inherit (sa) backendPort idleTimeout startTimeout;
        systemdPackage = config.systemd.package;
      }))
    ];

    my.services.caddy.reverseProxyHosts = my.lib.caddy.mkReverseProxy cfg;
  };
}
