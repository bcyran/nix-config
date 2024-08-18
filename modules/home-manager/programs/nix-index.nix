{
  config,
  lib,
  ...
}: let
  cfg = config.my.programs.nix-index;
in {
  options.my.programs.nix-index.enable = lib.mkEnableOption "nix-index";

  config = lib.mkIf cfg.enable {
    programs.nix-index = {
      enable = true;
      enableFishIntegration = true;
    };
  };
}
