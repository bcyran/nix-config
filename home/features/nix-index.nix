{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.my.programs.nix-index;
in {
  options.my.programs.nix-index.enable = mkEnableOption "nix-index";

  config = mkIf cfg.enable {
    programs.nix-index = {
      enable = true;
      enableFishIntegration = true;
    };
  };
}
