{
  config,
  lib,
  ...
}: let
  inherit (lib) mkDefault;
  cfg = config.my.presets.desktop;
in {
  options.my.presets.desktop.enable = lib.mkEnableOption "desktop";

  config = lib.mkIf cfg.enable {
    my = {
      configurations = {
        bluetooth.enable = mkDefault true;
        audio.enable = mkDefault true;
        ddcci.enable = mkDefault true;
        backlight.enable = mkDefault true;
        fileManagement.enable = mkDefault true;
        silentboot.enable = mkDefault true;
      };
      programs = {
        logiops.enable = mkDefault true;
      };
    };

    services = {
      systemd-lock-handler.enable = true; # Required for `lock.target` in user's systemd
    };

    security = {
      polkit.enable = true;
    };
  };
}
