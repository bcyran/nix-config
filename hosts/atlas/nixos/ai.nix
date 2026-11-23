{
  config,
  my,
  pkgs,
  ...
}: let
  intraDomain = my.lib.const.domains.intra;
in {
  sops.secrets = {
    llama_swap_env_file = {
      restartUnits = ["llama-swap.service"];
    };
  };

  systemd.tmpfiles.rules = [
    "d ${my.lib.const.paths.atlas.models} 0755 root root -"
  ];

  my.services = {
    llama-swap = {
      enable = true;
      llamaCppPackage = pkgs.llama-cpp-cuda;
      gpuMonitoringTools = [config.hardware.nvidia.package.bin];
      modelsDir = "${my.lib.const.paths.atlas.models}/llama";
      ttl = 900;
      reverseProxy.domain = "llama.${intraDomain}";
      environmentFile = config.sops.secrets.llama_swap_env_file.path;
      models = let
        kvCacheCompact = ["--cache-type-k q8_0" "--cache-type-v q8_0"];
        kvCacheExtraCompact = ["--cache-type-k q8_0" "--cache-type-v q4_0"];
      in {
        qwen38 = {
          name = "Qwen 3.8 27B";
          hf = "unsloth/Qwen3.8-27B-GGUF:UD-Q4_K_M";
          contextSize = 131072;
          extraArgs =
            ["--temp 1.0" "--top-p 0.95" "--top-k 20" "--min-p 0"]
            ++ kvCacheExtraCompact
            ++ [
              "--spec-type draft-mtp"
              "--spec-draft-model ${my.lib.const.paths.atlas.models}/llama/mtp-Qwen3.8-27B-Q4_0.gguf"
              "--spec-draft-n-max 3"
              # The GPU has no room for the vision tower at this context size.
              # Keep it in host RAM: image requests are slower but I use it only occasionally so it's a good compromise.
              "--no-mmproj-offload"
              "--image-min-tokens 1024"
            ];
        };
        qwen3-coder = {
          name = "Qwen 3 Coder 30B";
          hf = "unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF:UD-Q4_K_XL";
          contextSize = 131072;
          extraArgs =
            ["--temp 0.7" "--top-p 0.8" "--top-k 20" "--min-p 0" "--repeat-penalty 1.05"]
            ++ kvCacheExtraCompact;
        };
        north-mini-code1 = {
          name = "North Mini Code";
          hf = "unsloth/North-Mini-Code-1.0-GGUF:UD-Q4_K_S";
          contextSize = 131072;
          extraArgs = ["--temp 1.0" "--top-p 0.95"];
        };
        glm47-flash = {
          name = "GLM 4.7 Flash";
          hf = "unsloth/GLM-4.7-Flash-GGUF:UD-Q4_K_XL";
          contextSize = 131072;
          extraArgs = ["--temp 0.7" "--top-p 1.0" "--min-p 0.01"];
        };
        nemotron-cascade2 = {
          name = "Nemotron Cascade 2";
          hf = "bartowski/nvidia_Nemotron-Cascade-2-30B-A3B-GGUF:IQ4_XS";
          contextSize = 131072;
          extraArgs = ["--temp 1.0" "--top-p 0.95"];
        };
        devstral-small2 = {
          name = "Devstral Small 2";
          hf = "unsloth/Devstral-Small-2-24B-Instruct-2512-GGUF:UD-Q3_K_XL";
          contextSize = 131072;
          extraArgs =
            ["--temp 0.15"]
            ++ kvCacheExtraCompact;
        };
        flint = {
          name = "Flint";
          hf = "unsloth/flint-GGUF:UD-Q3_K_XL";
          contextSize = 131072;
          extraArgs = ["--temp 1.0" "--top-p 0.95" "--top-k 20" "--min-p 0"];
        };
        gemma4-26b = {
          name = "Gemma 4 26B A4B";
          hf = "unsloth/gemma-4-26B-A4B-it-qat-GGUF:UD-Q4_K_XL";
          contextSize = 131072;
          extraArgs = ["--temp 1.0" "--top-p 0.95" "--top-k 64"];
        };
        gemma4-31b = {
          name = "Gemma 4 31B";
          hf = "unsloth/gemma-4-31B-it-qat-GGUF:UD-Q4_K_XL";
          contextSize = 65536;
          extraArgs =
            ["--temp 1.0" "--top-p 0.95" "--top-k 64"]
            ++ kvCacheCompact
            ++ [
              "--spec-type draft-mtp"
              "--spec-draft-model ${my.lib.const.paths.atlas.models}/llama/mtp-gemma-4-31B-it.gguf"
              "--spec-draft-n-max 3"
              "--no-mmproj"
            ];
        };
        gemma-small = {
          name = "Gemma 4 12B";
          hf = "unsloth/gemma-4-12B-it-qat-GGUF:UD-Q4_K_XL";
          contextSize = 16384;
        };
      };
    };
    wyoming-openai-gateway.enable = true;
    open-webui = {
      enable = true;
      reverseProxy.domain = "openwebui.${intraDomain}";
    };
    comfyui = {
      enable = true;
      socketActivation.enable = true;
      modelsDir = "${my.lib.const.paths.atlas.models}/comfyui";
      reverseProxy.domain = "comfyui.${intraDomain}";
    };
    forgejo-mcp = {
      enable = true;
      reverseProxy.domain = "forgejo-mcp.${intraDomain}";
    };
  };
}
