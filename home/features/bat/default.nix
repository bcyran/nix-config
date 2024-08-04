{
  pkgs,
  config,
  ...
}: let
  inherit (config.colorScheme) slug name author palette;
  batTheme = pkgs.substituteAll ({
      name = "${slug}.tmTheme";
      src = ./bat.tmTheme;

      inherit author slug;
      themeName = name;
    }
    // palette);
in {
  programs.bat = {
    enable = true;
    config = {
      theme = slug;
    };
    themes = {
      "${slug}".src = batTheme;
    };
  };
  home.sessionVariables = {
    MANPAGER = "sh -c 'col -bx | bat -l man -p'";
    MANROFFOPT = "-c";
  };
}
