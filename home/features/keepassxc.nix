{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.my.programs.keepassxc;

  keepassxcPackage = pkgs.keepassxc;
  keepassxcBin = "${keepassxcPackage}/bin/keepassxc";
  keepassxcDesktopName = "org.keepassxc.KeePassXC.desktop";
  # keepassxcDesktop = "${keepassxcPackage}/share/applications/${keepassxcDesktopName}";
in {
  options.my.programs.keepassxc.enable = mkEnableOption "keepassxc";

  config = mkIf cfg.enable {
    home.packages = [keepassxcPackage];
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
        FdoSecrets = {
          Enabled = true;
        };
      };
    };
    xdg.configFile."autostart/${keepassxcDesktopName}" = {
      # source = keepassxcDesktop;
      # FIXME: For some reason SSH_AUTH_SOCK env is not available to keepassxc if not set explictly.
      #        Setting AuthSockOverride in the config does not work too.
      text = ''
        [Desktop Entry]
        Name=KeePassXC
        GenericName=Password Manager
        GenericName[pl]=Menedżer haseł
        Comment=Community-driven port of the Windows application “KeePass Password Safe”
        Exec=env QT_QPA_PLATFORM=wayland SSH_AUTH_SOCK=/run/user/1000/ssh-agent ${keepassxcBin} %f
        TryExec=keepassxc
        Icon=keepassxc
        StartupWMClass=keepassxc
        StartupNotify=true
        Terminal=false
        Type=Application
        Version=1.5
        Categories=Utility;Security;Qt;
        MimeType=application/x-keepass2;
        SingleMainWindow=true
        X-GNOME-SingleWindow=true
        Keywords=security;privacy;password-manager;yubikey;password;keepass;
      '';
    };
  };
}
