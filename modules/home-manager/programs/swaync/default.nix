{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  inherit (config.colorScheme) palette;
  cfg = config.my.programs.swaync;

  swaync = pkgs.swaynotificationcenter;
  swayncBin = "${swaync}/bin/swaync";
  swayncClientBin = "${swaync}/bin/swaync-client";

  configFormat = pkgs.formats.json {};
  styleSheet = builtins.readFile ./style.css;
in {
  options.my.programs.swaync.enable = mkEnableOption "swaync";

  config = mkIf cfg.enable {
    home.packages = [pkgs.swaynotificationcenter];

    systemd.user.services.swaync = {
      Unit = {
        Description = "Swaync notification daemon";
        Documentation = "https://github.com/ErikReider/SwayNotificationCenter";
        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target"];
        ConditionEnvironment = "WAYLAND_DISPLAY";
      };
      Service = {
        Type = "dbus";
        BusName = "org.freedesktop.Notifications";
        ExecStart = "${swayncBin}";
        ExecReload = "${swayncClientBin} --reload-config";
        Restart = "on-failure";
      };
      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };

    xdg.configFile."swaync/config.json".source = configFormat.generate "config.json" {
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

    xdg.configFile."swaync/style.css".text = ''
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

      ${styleSheet}
    '';
  };
}
