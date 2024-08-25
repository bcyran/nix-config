{
  config,
  lib,
  ...
}: let
  cfg = config.my.programs.starship;
in {
  options.my.programs.starship.enable = lib.mkEnableOption "starship";

  config = lib.mkIf cfg.enable {
    programs.starship.enable = true;
    xdg.configFile."starship.toml".source = ./starship.toml;
  };
}
