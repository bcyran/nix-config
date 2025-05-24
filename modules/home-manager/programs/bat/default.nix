{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (config.colorScheme) slug name author palette;
  cfg = config.my.programs.bat;

  batTheme = pkgs.replaceVars ./bat.tmTheme ({
      inherit author slug;
      themeName = name;
    }
    // {
      inherit
        (palette)
        base00
        base01
        base02
        base03
        base04
        base05
        base07
        base08
        base09
        base0A
        base0B
        base0C
        base0D
        base0E
        base0F
        ;
    });
in {
  options.my.programs.bat.enable = lib.mkEnableOption "bat";

  config = lib.mkIf cfg.enable {
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
