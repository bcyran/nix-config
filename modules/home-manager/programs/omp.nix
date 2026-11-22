{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.programs.omp;

  yamlFormat = pkgs.formats.yaml {};
  jsonFormat = pkgs.formats.json {};

  providers =
    lib.mapAttrs (
      _: provider:
        {
          inherit (provider) baseUrl;
          api = "openai-completions";
          models =
            lib.mapAttrsToList (
              id: model: {
                inherit id;
                inherit (model) name;
                contextWindow = model.contextSize;
                maxTokens = lib.max 4096 (model.contextSize / 5);
                compat.maxTokensField = "max_tokens";
              }
            )
            provider.models;
        }
        // lib.optionalAttrs (provider.apiKeyEnvVar != null) {
          apiKey = provider.apiKeyEnvVar;
          authHeader = true;
        }
    )
    cfg.customProviders;

  configFile = yamlFormat.generate "omp-config.yml" {
    symbolPreset = "nerd";
    composer.shape = "claude";
    theme.dark = "dark-tokyo-night";
    setupVersion = 3;
    modelRoles.default = cfg.defaultModel;
    defaultThinkingLevel = "low";
    hideThinkingBlock = true;
  };
  modelsFile = yamlFormat.generate "omp-models.yml" {
    inherit providers;
  };
  mcpServers = {
    codegraph = {
      type = "stdio";
      command = lib.getExe pkgs.codegraph;
      args = ["serve" "--mcp"];
    };
    nixos = {
      type = "stdio";
      command = lib.getExe pkgs.mcp-nixos;
    };
  };

  mcpFile = jsonFormat.generate "omp-mcp.json" {
    "$schema" = "https://raw.githubusercontent.com/can1357/oh-my-pi/main/packages/coding-agent/src/config/mcp-schema.json";
    mcpServers = mcpServers // cfg.extraMcpServers;
  };
in {
  options.my.programs.omp = {
    enable = lib.mkEnableOption "omp";

    defaultModel = lib.mkOption {
      type = lib.types.str;
      default = "llama.cpp/qwen38";
      description = "Model used for the default role in ~/.omp/agent/config.yml.";
    };

    customProviders = lib.mkOption {
      default = {};
      description = "Custom OpenAI-compatible providers written to ~/.omp/agent/models.yml.";
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          baseUrl = lib.mkOption {
            type = lib.types.str;
            example = "https://llama.example.com/v1";
            description = "OpenAI-compatible base URL of the provider.";
          };
          apiKeyEnvVar = lib.mkOption {
            type = with lib.types; nullOr str;
            default = null;
            example = "ATLAS_LLAMA_API_KEY";
            description = "Name of the environment variable containing the API key.";
          };
          models = lib.mkOption {
            default = {};
            description = "Models served by the provider, keyed by the model ID used in API requests.";
            type = lib.types.attrsOf (lib.types.submodule {
              options = {
                name = lib.mkOption {
                  type = lib.types.str;
                  example = "Qwen3.8 27B";
                  description = "Display name in omp.";
                };
                contextSize = lib.mkOption {
                  type = lib.types.ints.positive;
                  example = 65536;
                  description = "Context size in tokens.";
                };
              };
            });
          };
        };
      });
    };

    extraMcpServers = lib.mkOption {
      type = lib.types.attrsOf jsonFormat.type;
      default = {};
      description = "Additional MCP servers written to ~/.omp/agent/mcp.json.";
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      packages = [pkgs.omp];

      file = {
        ".omp/agent/config.yml".source = configFile;
        ".omp/agent/models.yml".source = modelsFile;
        ".omp/agent/mcp.json".source = mcpFile;
      };
    };
  };
}
