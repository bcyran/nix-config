{pkgs, ...}: {
  home.packages = with pkgs; [
    signal-desktop
  ];
  xdg.configFile."Signal/ephemeral.json" = {
    text = ''
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
  };
}
