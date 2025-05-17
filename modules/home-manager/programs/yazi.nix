{
  config,
  lib,
  ...
}: let
  cfg = config.my.programs.yazi;
in {
  options.my.programs.yazi.enable = lib.mkEnableOption "yazi";

  config = lib.mkIf cfg.enable {
    programs.yazi = {
      enable = true;
      enableFishIntegration = true;
    };
  };
}
