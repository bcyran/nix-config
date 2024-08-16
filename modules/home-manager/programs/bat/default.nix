{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  inherit (config.colorScheme) slug name author palette;
  cfg = config.my.programs.bat;

  batTheme = pkgs.substituteAll ({
      name = "${slug}.tmTheme";
      src = ./bat.tmTheme;

      inherit author slug;
      themeName = name;
    }
    // palette);
in {
  options.my.programs.bat.enable = mkEnableOption "bat";

  config = mkIf cfg.enable {
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
  };
}
