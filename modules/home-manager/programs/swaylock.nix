{
  config,
  lib,
  ...
}: let
  inherit (config.colorScheme) palette;
  cfg = config.my.programs.swaylock;
in {
  options.my.programs.swaylock.enable = lib.mkEnableOption "swaylock";

  config = lib.mkIf cfg.enable {
    programs.swaylock = {
      enable = true;
      settings = {
        color = "#${palette.base00}";

        font = builtins.elemAt config.fonts.fontconfig.defaultFonts.sansSerif 0;
        font-size = 50;
        indicator-idle-visible = true;

        text-color = "#${palette.base05}";
        inside-color = "#${palette.base00}";
        inside-ver-color = "#${palette.base00}";
        inside-wrong-color = "#${palette.base00}";
        line-uses-inside = true;
        separator-color = "#${palette.base00}";
        indicator-radius = 120;

        ring-color = "#${palette.accentPrimary}";
        ring-ver-color = "#${palette.warning}";
        ring-wrong-color = "#${palette.error}";
        key-hl-color = "#${palette.accentSecondary}";

        text-wrong-color = "#${palette.base05}";
        text-ver-color = "#${palette.base05}";
      };
    };
  };
}
