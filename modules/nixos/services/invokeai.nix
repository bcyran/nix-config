{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.invokeai;

  # renovate: datasource=docker packageName=ghcr.io/invoke-ai/invokeai
  imageVersion = "6.14.4-cuda";
  dataDir = "/var/lib/invokeai";
  uid = 2009;
in {
  options.my.services.invokeai = let
    serviceName = "InvokeAI";
  in {
    enable = lib.mkEnableOption serviceName;
    user = my.lib.options.mkUserOption serviceName;
    group = my.lib.options.mkGroupOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 8106;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;

    modelsDir = lib.mkOption {
      type = lib.types.path;
      example = "/mnt/fast_store/models/invokeai";
      description = "The directory where models are kept. Everything else lives in ${dataDir}.";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];

      hardware.nvidia-container-toolkit.enable = true;

      virtualisation.oci-containers.containers.invokeai = {
        image = "ghcr.io/invoke-ai/invokeai:${imageVersion}";
        autoStart = true;
        ports = [
          "${cfg.address}:${builtins.toString cfg.port}:${builtins.toString cfg.port}"
        ];
        volumes = [
          "${dataDir}:/invokeai"
          "${cfg.modelsDir}:/invokeai/models"
        ];
        environment = {
          INVOKEAI_PORT = builtins.toString cfg.port;
          INVOKEAI_MULTIUSER = "true";
          INVOKEAI_MAX_CACHE_RAM_GB = "6";
          INVOKEAI_KEEP_RAM_COPY_OF_WEIGHTS = "false";
          HOME = "/invokeai";
          HF_HOME = "/invokeai/.cache/huggingface";
          MPLCONFIGDIR = "/invokeai/.matplotlib";
        };
        # The stock entrypoint needs root to switch to its own user. Skip it and run
        # as the service user instead.
        entrypoint = "invokeai-web";
        extraOptions = [
          "--userns=keep-id"
          "--workdir=/invokeai"
          "--device=nvidia.com/gpu=all"
          "--cap-drop=ALL"
          "--security-opt=no-new-privileges"
        ];
        podman.user = cfg.user;
      };

      systemd.tmpfiles.rules = [
        "d '${dataDir}' 0750 ${cfg.user} ${cfg.group} - -"
        "d '${cfg.modelsDir}' 0750 ${cfg.user} ${cfg.group} - -"
      ];

      my.services.caddy.reverseProxyHosts = my.lib.caddy.mkReverseProxy cfg;
    }

    (my.lib.ociContainers.mkRootlessPodmanUser {
      inherit (cfg) user group;
      home = dataDir;
      inherit uid;
    })
  ]);
}
