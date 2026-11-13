{
  lib,
  my,
  ...
}: let
  atlasLlamaSwap = my.nixosConfigurations.atlas.config.my.services.llama-swap;
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
}
