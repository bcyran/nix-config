{
  config,
  lib,
  ...
}: let
  cfg = config.my.programs.keepassxc;
in {
  options.my.programs.keepassxc.enable = lib.mkEnableOption "keepassxc";

  config = lib.mkIf cfg.enable {
    programs.keepassxc = {
      enable = true;
      autostart = true;
      settings = {
        General = {
          ConfigVersion = 2;
          HideWindowOnCopy = true;
        };
        GUI = {
          ApplicationTheme = "dark";
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
          HttpAuthPermission = true;
          # Home Manager installs the native messaging manifest into the read-only
          # Nix store, so KeePassXC cannot rewrite it on startup and pops up
          # "Could not save the native messaging script file for chromium".
          # The store-provided manifest is already up to date, so keep KeePassXC
          # from touching it.
          UpdateBinaryPath = false;
        };
        SSHAgent = {
          Enabled = false;
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
          ShowNotification = true;
          ConfirmAccessItem = false;
          ConfirmDeleteItem = false;
          UnlockBeforeSearch = true;
        };
      };
    };
  };
}
