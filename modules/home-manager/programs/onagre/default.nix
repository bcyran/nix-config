{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.my.programs.onagre;

  themeFile = pkgs.substituteAll ({
      name = "theme.scss";
      src = ./files/theme.scss;
    }
    // config.colorScheme.palette);
in {
  options.my.programs.onagre.enable = mkEnableOption "onagre";

  config = mkIf cfg.enable {
    home.packages = [pkgs.onagre];
    xdg.configFile."onagre/theme.scss".source = themeFile;
  };
}
