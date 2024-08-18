{
  config,
  lib,
  ...
}: let
  cfg = config.my.programs.direnv;
in {
  options.my.programs.direnv.enable = lib.mkEnableOption "direnv";

  config = lib.mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      config = {
        hide_env_diff = true;
      };
      nix-direnv.enable = true;
    };
  };
}
