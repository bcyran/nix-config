{
  lib,
  my,
  ...
}: let
  atlasLlamaSwap = my.nixosConfigurations.atlas.config.my.services.llama-swap;
  atlasForgejoMcp = my.nixosConfigurations.atlas.config.my.services.forgejo-mcp;
in {
  my.programs.opencode.customProviders.atlas-llama = lib.mkIf atlasLlamaSwap.enable {
    name = "Atlas Llama";
    baseUrl = "https://${atlasLlamaSwap.reverseProxy.domain}/v1";
    apiKeyEnvVar = "ATLAS_LLAMA_API_KEY";
    models =
      lib.mapAttrs (id: model: {
        name =
          if model.name != null
          then model.name
          else id;
        inherit (model) contextSize;
      })
      atlasLlamaSwap.models;
  };

  # Remote MCP server; each client authenticates with its own Forgejo PAT
  # (user-provided env var, no shared service secret).
  programs.opencode.settings.mcp.servers.forgejo =
    lib.mkIf (
      atlasForgejoMcp.enable && atlasForgejoMcp.reverseProxy.domain != null
    ) {
      type = "remote";
      url = "https://${atlasForgejoMcp.reverseProxy.domain}/mcp";
      oauth = false;
      headers = {
        Authorization = "Bearer {env:FORGEJO_MCP_TOKEN}";
      };
    };
}
