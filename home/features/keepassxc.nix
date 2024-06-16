{pkgs, ...}: let
  keepassxc = pkgs.keepassxc;
  keepassxcDesktopName = "org.keepassxc.KeePassXC.desktop";
  keepassxcDesktop = "${keepassxc}/share/applications/${keepassxcDesktopName}";
in {
  home.packages = [keepassxc];
  xdg.configFile."keepassxc/keepassxc.ini" = {
    text = pkgs.lib.generators.toINI {} {
      General = {
        ConfigVersion = 2;
        HideWindowOnCopy = true;
      };
      GUI = {
        CompactMode = true;
        HidePasswords = true;
        MinimizeOnClose = true;
        ShowTrayIcon = true;
        TrayIconAppearance = "monochrome-light";
      };
      Browser = {
        CustomProxyLocation = "";
        Enabled = true;
        SearchInAllDatabases = true;
      };
      SSHAgent = {
        Enabled = true;
      };
      PasswordGenerator = {
        Length = 20;
        LowerCase = true;
        UpperCase = true;
        SpecialChars = true;
        Math = true;
      };
      Security = {
        IconDownloadFallback = true;
      };
    };
  };
  xdg.configFile."autostart/${keepassxcDesktopName}" = {
    source = keepassxcDesktop;
  };
}
