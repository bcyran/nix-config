{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (pkgs) signal-desktop;
  cfg = config.my.programs.signal;
in {
  options.my.programs.signal.enable = lib.mkEnableOption "signal";

  config = lib.mkIf cfg.enable {
    home.packages = [signal-desktop];
    xdg.configFile."Signal/ephemeral.json".text = ''
      {
        "localeOverride": null,
        "system-tray-setting": "DoNotUseSystemTray",
        "theme-setting": "dark",
        "spell-check": true,
        "window": {
          "maximized": false,
          "autoHideMenuBar": true,
          "fullscreen": false
        }
      }
    '';
    xdg.autostart.entries = [
      "${signal-desktop}/share/applications/signal-desktop.desktop"
    ];
  };
}
