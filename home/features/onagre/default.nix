{
  pkgs,
  config,
  ...
}: let
  theme = pkgs.substituteAll ({
      name = "theme.scss";
      src = ./files/theme.scss;
    }
    // config.colorScheme.palette);
in {
  home.packages = [pkgs.onagre];
  xdg.configFile."onagre/theme.scss" = {
    source = theme;
  };
}
