{
  config,
  lib,
  ...
}: let
  inherit (config.colorScheme) palette;
  cfg = config.my.programs.swaync;

  styleSheet = builtins.readFile ./style.css;
in {
  options.my.programs.swaync.enable = lib.mkEnableOption "swaync";

  config = lib.mkIf cfg.enable {
    services.swaync = {
      enable = true;

      settings = {
        notification-icon-size = 48;
        control-center-margin-top = 20;
        control-center-margin-right = 20;
        control-center-margin-bottom = 20;
        control-center-margin-left = 0;
        widgets = [
          "title"
          "dnd"
          "notifications"
        ];
        widget-config = {
          title = {
            text = "Centrum powiadomień";
            button-text = "Wyczyść wszystkie";
          };
          dnd = {
            text = "Nie przeszkadzać";
          };
        };
      };

      style = ''
        @define-color base00 #${palette.base00};
        @define-color base01 #${palette.base01};
        @define-color base02 #${palette.base02};
        @define-color base03 #${palette.base03};
        @define-color base04 #${palette.base04};
        @define-color base05 #${palette.base05};
        @define-color base06 #${palette.base06};
        @define-color base07 #${palette.base07};
        @define-color base08 #${palette.base08};
        @define-color base09 #${palette.base09};
        @define-color base0A #${palette.base0A};
        @define-color base0B #${palette.base0B};
        @define-color base0C #${palette.base0C};
        @define-color base0D #${palette.base0D};
        @define-color base0E #${palette.base0E};
        @define-color base0F #${palette.base0F};
        @define-color base10 #${palette.base10};
        @define-color base11 #${palette.base11};
        @define-color base12 #${palette.base12};
        @define-color base13 #${palette.base13};
        @define-color base14 #${palette.base14};
        @define-color base15 #${palette.base15};
        @define-color base16 #${palette.base16};
        @define-color base17 #${palette.base17};

        @define-color accent_primary #${palette.accentPrimary};
        @define-color accent_secondary #${palette.accentSecondary};
        @define-color warning #${palette.warning};
        @define-color error #${palette.error};

        * {
          font-family: "${builtins.elemAt config.fonts.fontconfig.defaultFonts.sansSerif 0}";
        }

        ${styleSheet}
      '';
    };
  };
}
