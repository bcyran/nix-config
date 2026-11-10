{
  my,
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.services.llama-swap;

  llamaServer = lib.getExe' cfg.llamaCppPackage "llama-server";
  mkModelCmd = model:
    lib.concatStringsSep " " ([
        llamaServer
        "--port \${PORT}"
        "--hf-repo ${model.hf}"
        "--ctx-size ${toString model.contextSize}"
        "--n-gpu-layers 999"
        "--flash-attn on"
        "--jinja"
        "--no-webui"
      ]
      ++ model.extraArgs);
in {
  options.my.services.llama-swap = let
    serviceName = "llama-swap";
  in {
    enable = lib.mkEnableOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 11435;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;
    environmentFile = my.lib.options.mkEnvironmentFileOption serviceName;

    llamaCppPackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.llama-cpp-cuda;
      defaultText = lib.literalExpression "pkgs.llama-cpp-cuda";
      description = "The llama.cpp package that provides `llama-server`.";
    };

    supplementaryGroup = lib.mkOption {
      type = lib.types.str;
      default = "llm-models";
      description = "Group that owns `modelsDir`. The service and your user are members, so both can write there. Must not match the service's dynamic user name (`llama-swap`).";
    };

    modelsDir = lib.mkOption {
      type = lib.types.path;
      example = "/mnt/fast_store/llm";
      description = "The path to the directory where ${serviceName} stores and reads GGUF model files.";
    };

    ttl = lib.mkOption {
      type = lib.types.ints.unsigned;
      default = 600;
      description = "Seconds of inactivity after which a model is unloaded from VRAM. 0 means never.";
    };

    models = lib.mkOption {
      default = {};
      description = "Models served by llama.cpp (CUDA), keyed by the model ID used in API requests.";
      example = lib.literalExpression ''
        {
          coder = {
            hf = "unsloth/Qwen3.8-27B-GGUF:UD-Q4_K_M";
            contextSize = 65536;
            extraArgs = ["--cache-type-k q8_0" "--cache-type-v q8_0"];
          };
        }
      '';
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = with lib.types; nullOr str;
            default = null;
            example = "Qwen 3.8 27B";
            description = "Human-readable display name.";
          };
          hf = lib.mkOption {
            type = with lib.types; nullOr str;
            default = null;
            example = "unsloth/Qwen3.8-27B-GGUF:UD-Q4_K_M";
            description = ''
              Hugging Face repository and quantization (`--hf-repo`).
              llama.cpp downloads the model into `modelsDir` on first load.
            '';
          };
          contextSize = lib.mkOption {
            type = lib.types.ints.positive;
            default = 32768;
            description = "Context size in tokens (`--ctx-size`).";
          };
          extraArgs = lib.mkOption {
            type = with lib.types; listOf str;
            default = [];
            example = ["--temp 0.6" "--cache-type-k q8_0"];
            description = "Additional `llama-server` arguments.";
          };
        };
      });
    };
  };

  config = lib.mkIf cfg.enable {
    services.llama-swap = {
      enable = true;
      listenAddress = cfg.address;
      inherit (cfg) port openFirewall;
      # Validation fails due to API key env var missing in build time
      validateConfigFile = false;
      settings = {
        # The first load of a model includes its download.
        healthCheckTimeout = 3600;
        globalTTL = cfg.ttl;
        apiKeys = ["\${env.LLAMA_SWAP_API_KEY}"];
        models =
          lib.mapAttrs (_: model: {
            cmd = mkModelCmd model;
            inherit (model) name;
          })
          cfg.models;
      };
    };

    # A dynamic user's UID can't own `modelsDir`, so grant access through a static group instead.
    users.groups.${cfg.supplementaryGroup}.members = [config.my.user.name];

    systemd.services.llama-swap = {
      # llama.cpp downloads `--hf-repo` models into LLAMA_CACHE.
      environment.LLAMA_CACHE = lib.mkForce cfg.modelsDir;
      serviceConfig = {
        EnvironmentFile = cfg.environmentFile;
        SupplementaryGroups = [cfg.supplementaryGroup];
        UMask = "0002";
        ReadWritePaths = [cfg.modelsDir];
        # Supplementary groups are not reliably usable inside the user namespace.
        PrivateUsers = lib.mkForce false;
        # The NVIDIA driver and CUDA JIT need writable+executable memory mappings.
        MemoryDenyWriteExecute = lib.mkForce false;
      };
    };

    # setgid makes files created by the service or by you share the group.
    systemd.tmpfiles.rules = [
      "d '${cfg.modelsDir}' 2775 ${config.my.user.name} ${cfg.supplementaryGroup} - -"
    ];

    my.services.caddy.reverseProxyHosts = my.lib.caddy.mkReverseProxy cfg;
  };
}
