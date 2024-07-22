{pkgs, ...}: let
  signalPackage = pkgs.signal-desktop;
  signalDesktopName = "signal-desktop.desktop";
  signalDesktop = "${signalPackage}/share/applications/${signalDesktopName}";
in {
  home.packages = [signalPackage];
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
  xdg.configFile."autostart/${signalDesktopName}".source = signalDesktop;
}
