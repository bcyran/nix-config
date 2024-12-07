{
  config,
  lib,
  ...
}: let
  inherit (lib) mkDefault;
  cfg = config.my.presets.laptop;
in {
  options.my.presets.laptop.enable = lib.mkEnableOption "laptop";

  config = lib.mkIf cfg.enable {
    my.programs = {
      kanshi.enable = mkDefault true;
    };
  };
}
