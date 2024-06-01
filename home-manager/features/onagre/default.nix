{pkgs, ...}: {
  home.packages = [pkgs.onagre];
  xdg.configFile."onagre/theme.scss" = {
    source = ./files/theme.scss;
  };
}
