{
  config,
  lib,
  my,
  pkgs,
  ...
}: let
  cfg = config.my.programs.opencode;

  agentLib = my.inputs.agent-skills.lib.agent-skills;
  skillSources = agentLib.sourcesFromLock {
    manifestsDir = "${my}/agent-skills/sources";
    lockFile = "${my}/agent-skills/sources.lock.json";
  };

  providers = lib.mapAttrs (_: provider:
    {
      inherit (provider) name;
      package = "@opencode/ai/providers/openai-compatible";
      settings = {
        baseURL = provider.baseUrl;
      };
      compatibility.maxTokensField = "max_tokens";
      models =
        lib.mapAttrs (_: model: {
          inherit (model) name;
          limit = {
            context = model.contextSize;
            output = lib.max 4096 (model.contextSize / 5);
          };
          capabilities = {
            tools = true;
            input = ["text"];
            output = ["text"];
          };
        })
        provider.models;
    }
    // lib.optionalAttrs (provider.apiKeyEnvVar != null) {
      env = [provider.apiKeyEnvVar];
    })
  cfg.customProviders;
in {
  options.my.programs.opencode = {
    enable = lib.mkEnableOption "opencode";

    customProviders = lib.mkOption {
      default = {};
      description = "Custom OpenAI-compatible providers";
      type = lib.types.attrsOf (lib.types.submodule ({name, ...}: {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
            default = name;
            example = "llama-swap";
            description = "Display name in opencode. Defaults to the provider ID.";
          };
          baseUrl = lib.mkOption {
            type = lib.types.str;
            example = "https://llama.example.com/v1";
            description = "OpenAI-compatible base URL of the provider.";
          };
          apiKeyEnvVar = lib.mkOption {
            type = with lib.types; nullOr str;
            default = null;
            example = "LLAMA_SWAP_API_KEY";
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
                  description = "Display name in opencode.";
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
      }));
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.rtk
      pkgs.codegraph
    ];

    programs.opencode = {
      enable = true;
      settings =
        {
          autoupdate = false;
          plugin = [
            "opencode-rules@latest"
            "${pkgs.rtk.src}/hooks/opencode/rtk.ts"
          ];
          permission = {
            external_directory = {
              "/nix/store/**" = "allow";
            };
            read = {
              "*" = "allow";
              "*.env" = "deny";
              "*.env.*" = "deny";
              "*.env.example" = "allow";
              "~/.ssh" = "deny";
              "~/.ssh/**" = "deny";
            };
            edit = {
              "*" = "allow";
              "/nix/**" = "deny";
              "/etc/**" = "deny";
              "~/.ssh" = "deny";
              "~/.ssh/**" = "deny";
            };
            bash = {
              "ssh *" = "deny";
              "scp *" = "deny";
              "sftp *" = "deny";
              "* ~/.ssh" = "deny";
              "* ~/.ssh/*" = "deny";
            };
          };
          mcp.servers = {
            codegraph = {
              type = "local";
              command = [
                (lib.getExe pkgs.codegraph)
                "serve"
                "--mcp"
              ];
            };
            nixos = {
              type = "local";
              command = [(lib.getExe pkgs.mcp-nixos)];
            };
          };
        }
        // lib.optionalAttrs (providers != {}) {inherit providers;};
      cli.theme.name = "tokyonight";
    };

    programs.agent-skills = {
      enable = true;
      sources = skillSources;
      skills.enable = [
        "simple-english"
        "engineering/grill-with-docs"
        "productivity/grilling"
        "engineering/domain-modeling"
        "caveman"
        "ponytail"
        "i-have-adhd"
      ];
      targets.opencode.enable = true;
    };
  };
}
