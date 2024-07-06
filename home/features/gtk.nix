{
  pkgs,
  config,
  ...
}: let
  inherit (config.colorScheme) palette;
  themeCSS = ''
    @define-color window_bg_color #${palette.base10};
    @define-color window_fg_color #${palette.base05};
    @define-color headerbar_bg_color #${palette.base11};
    @define-color headerbar_fg_color @window_fg_color;
    @define-color headerbar_backdrop_color_color @window_bg_color;
    @define-color view_bg_color #${palette.base00};
    @define-color view_fg_color @window_fg_color;
    @define-color sidebar_bg_color @window_bg_color;
    @define-color sidebar_fg_color @window_fg_color;
    @define-color sidebar_backdrop_color @window_bg_color;
    @define-color popover_bg_color @view_bg_color;
    @define-color popover_fg_color @view_fg_color;
    @define-color dialog_bg_color @view_bg_color;
    @define-color dialog_fg_color @view_fg_color;
    @define-color card_bg_color #${palette.base01};
    @define-color card_fg_color @window_fg_color;

    @define-color accent_bg_color #${palette.accentPrimary};
    @define-color accent_fg_color @view_bg_color;
    @define-color accent_color @accent_bg_color;
    @define-color warning_bg_color #${palette.warning};
    @define-color warning_fg_color @view_bg_color;
    @define-color warning_color @warning_bg_color;
    @define-color error_bg_color #${palette.error};
    @define-color error_fg_color @view_bg_color;
    @define-color error_color @error_bg_color;
    @define-color success_bg_color #${palette.base0B};
    @define-color success_fg_color @view_bg_color;
    @define-color success_color @success_bg_color;
    @define-color destructive_bg_color #${palette.base0F};
    @define-color destructive_fg_color @window_fg_color;
    @define-color destructive_color @destructive_bg_color;
  '';
in {
  gtk = {
    enable = true;

    font = {
      name = "Roboto";
      package = pkgs.roboto;
      size = 12;
    };

    iconTheme = {
      name = "Qogir";
      package = pkgs.qogir-icon-theme;
    };

    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
  };

  home.pointerCursor = {
    package = pkgs.numix-cursor-theme;
    name = "Numix-Cursor-Light";
    size = 16;
    gtk.enable = true;
    x11.enable = true;
  };
  xdg.configFile = {
    "gtk-4.0/gtk.css".text = themeCSS;
    "gtk-3.0/gtk.css".text = themeCSS;
  };
}
