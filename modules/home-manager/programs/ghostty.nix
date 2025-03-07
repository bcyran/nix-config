{
  config,
  lib,
  ...
}: let
  cfg = config.my.programs.ghostty;

  themeName = config.colorScheme.slug;
  inherit (config.colorScheme) palette;
in {
  options.my.programs.ghostty.enable = lib.mkEnableOption "ghostty";

  config = lib.mkIf cfg.enable {
    programs.ghostty = {
      enable = true;
      enableFishIntegration = true;
      installVimSyntax = true;
      installBatSyntax = true;
      settings = {
        theme = themeName;
        font-size = 14;
        font-family = builtins.elemAt config.fonts.fontconfig.defaultFonts.monospace 0;
      };
      themes.${themeName} = {
        background = palette.base00;
        foreground = palette.base05;
        selection-background = palette.base02;
        selection-foreground = palette.base05;
        cursor-color = palette.base05;
        cursor-text = palette.base00;
        palette = [
          "0=${palette.base00}"
          "1=${palette.base08}"
          "2=${palette.base0B}"
          "3=${palette.base0A}"
          "4=${palette.base0D}"
          "5=${palette.base0E}"
          "6=${palette.base0C}"
          "7=${palette.base05}"
          "8=${palette.base02}"
          "9=${palette.base08}"
          "10=${palette.base0B}"
          "11=${palette.base0A}"
          "12=${palette.base0D}"
          "13=${palette.base0E}"
          "14=${palette.base0C}"
          "15=${palette.base07}"
        ];
      };
    };
  };
}
