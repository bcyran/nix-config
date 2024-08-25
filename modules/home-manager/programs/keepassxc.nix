{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.my.programs.keepassxc;

  keepassxcPackage = pkgs.keepassxc;
  keepassxcBin = "${keepassxcPackage}/bin/keepassxc";
in {
  options.my.programs.keepassxc.enable = lib.mkEnableOption "keepassxc";

  config = lib.mkIf cfg.enable {
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
    xdg.configFile."autostart/org.keepassxc.KeePassXC.desktop".source = let
      sshAgentSock = "/run/user/${toString config.my.user.uid}/ssh-agent";
      desktopItem = pkgs.makeDesktopItem {
        name = "org.keepassxc.KeePassXC";
        desktopName = "KeePassXC";
        genericName = "Password Manager";
        comment = "Community-driven port of the Windows application “KeePass Password Safe”";
        exec = "env QT_QPA_PLATFORM=wayland SSH_AUTH_SOCK=${sshAgentSock} ${keepassxcBin} %f";
        tryExec = keepassxcBin;
        icon = "keepassxc";
        startupWMClass = "keepassxc";
        startupNotify = true;
        terminal = false;
        type = "Application";
        categories = ["Utility" "Security" "Qt"];
        mimeTypes = ["application/x-keepass2"];
        keywords = ["security" "privacy" "password-manager" "yubikey" "password" "keepass"];
      };
    in "${desktopItem}/share/applications/org.keepassxc.KeePassXC.desktop";
  };
}
