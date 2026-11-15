{
  my,
  config,
  lib,
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
  };

  config = lib.mkIf cfg.enable {
    services.comfyui = {
      enable = true;
      inherit (cfg) port;
      listen = [cfg.address];
      extraArgs = [
        # ComfyUI's DynamicVRAM stages every loaded model in a pinned host buffer sized
        # from free RAM, which cannot be swapped out. Unpinned pages can be, so offload
        # through the NVMe instead and keep some VRAM free for the VAE decode spike.
        "--disable-pinned-memory"
        "--fast-disk"
        "--vram-headroom"
        "1.5"
        # Drops the paid partner/API nodes and serves the frontend with a CSP that
        # only allows connections back to this origin.
        "--offline"
        "--disable-product-tips"
      ];
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];

    systemd.tmpfiles.rules = lib.mkIf (cfg.modelsDir != null) [
      "d ${cfg.modelsDir} 0700 comfyui comfyui -"
      "d ${config.services.comfyui.dataDir}/models 0700 comfyui comfyui -"
    ];

    systemd.services.comfyui = lib.mkIf (cfg.modelsDir != null) {
      preStart = lib.mkBefore ''
        # The models directory is bind-mounted, so populate its default layout ourselves.
        # The host path is read-only inside the unit (ProtectSystem=strict); use the
        # bind-mounted view instead.
        if [ -z "$(ls -A ${config.services.comfyui.dataDir}/models)" ]; then
          cp --no-preserve=all -r ${config.services.comfyui.finalPackage}/share/comfyui/models/. ${config.services.comfyui.dataDir}/models/
          chmod -R u+rwX ${config.services.comfyui.dataDir}/models
        fi
      '';
      serviceConfig.BindPaths = ["${cfg.modelsDir}:${config.services.comfyui.dataDir}/models"];
    };

    my.services.caddy.reverseProxyHosts = my.lib.caddy.mkReverseProxy cfg;
  };
}
