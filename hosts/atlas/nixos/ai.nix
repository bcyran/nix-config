{
  config,
  my,
  pkgs,
  ...
}: let
  intraDomain = my.lib.const.domains.intra;
  agentsGroup = "agents";
  agentsDir = "/var/lib/agents";
in {
  sops.secrets = {
    opencode_env_file = {
      restartUnits = ["opencode.service"];
    };
    openchamber_env_file = {
      restartUnits = ["openchamber.service"];
    };
    llama_swap_env_file = {
      restartUnits = ["llama-swap.service"];
    };
  };

  users.groups.${agentsGroup} = {
    # Allow the human user to access files created by agent service users.
    members = [config.my.user.name];
  };

  # Ensure common agents directory exists.
  # Mode 2770: setgid ensures new subdirectories (e.g. cloned repos) inherit
  # the agents group, so service users can write to them.
  # NOTE: existing repos need a one-time fix:
  #   chown -R :agents /var/lib/agents && chmod -R g+rw /var/lib/agents
  # For ongoing correct permissions inside repos also run:
  #   git config core.sharedRepository group
  systemd.tmpfiles.rules = [
    "d ${agentsDir} 2770 ${config.my.user.name} ${agentsGroup} -"
    "d ${my.lib.const.paths.atlas.models} 0755 root root -"
  ];

  my.services = {
    opencode = {
      enable = true;
      group = agentsGroup;
      workingDirectory = agentsDir;
      git = {
        sshKeyFile = "/var/lib/opencode/.ssh/id_ed25519";
        userName = config.my.user.fullName;
        userEmail = config.my.user.email;
      };
    };
    openchamber = {
      enable = true;
      group = agentsGroup;
      reverseProxy.domain = "openchamber.${intraDomain}";
      environmentFile = config.sops.secrets.openchamber_env_file.path;
      workingDirectory = agentsDir;
      git = {
        sshKeyFile = "/var/lib/openchamber/.ssh/id_ed25519";
        userName = config.my.user.fullName;
        userEmail = config.my.user.email;
      };
    };
    llama-swap = {
      enable = true;
      llamaCppPackage = pkgs.llama-cpp-cuda;
      gpuMonitoringTools = [config.hardware.nvidia.package.bin];
      modelsDir = "${my.lib.const.paths.atlas.models}/llama";
      reverseProxy.domain = "llama.${intraDomain}";
      environmentFile = config.sops.secrets.llama_swap_env_file.path;
      models = let
        kvCacheCompact = ["--cache-type-k q8_0" "--cache-type-v q8_0"];
        kvCacheExtraCompact = ["--cache-type-k q8_0" "--cache-type-v q4_0"];
        qwenMtp = [
          "--spec-type draft-mtp"
          "--spec-draft-model ${my.lib.const.paths.atlas.models}/llama/mtp-Qwen3.8-27B-Q4_0.gguf"
          "--spec-draft-n-max 3"
        ];
      in {
        qwen38 = {
          name = "Qwen 3.8 27B";
          hf = "unsloth/Qwen3.8-27B-GGUF:UD-Q4_K_M";
          contextSize = 131072;
          extraArgs =
            ["--temp 1.0" "--top-p 0.95" "--top-k 20" "--min-p 0"]
            ++ kvCacheExtraCompact
            ++ qwenMtp
            # For most chats we disable multimodal projection but keep auto slots for better parallelism.
            ++ ["--no-mmproj"];
        };
        qwen38-multimodal = {
          name = "Qwen 3.8 27B (multimodal)";
          hf = "unsloth/Qwen3.8-27B-GGUF:UD-Q4_K_M";
          contextSize = 131072;
          extraArgs =
            ["--temp 1.0" "--top-p 0.95" "--top-k 20" "--min-p 0"]
            ++ kvCacheExtraCompact
            ++ qwenMtp
            # With multimodal projection, we only have enough VRAM for 1 slot.
            ++ ["--parallel 1"];
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
    open-webui = {
      enable = true;
      reverseProxy.domain = "openwebui.${intraDomain}";
    };
    invokeai = {
      enable = true;
      modelsDir = "${my.lib.const.paths.atlas.models}/invokeai";
      reverseProxy.domain = "invokeai.${intraDomain}";
    };
  };
}
