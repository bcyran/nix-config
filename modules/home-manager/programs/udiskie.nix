{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.my.programs.udiskie;
in {
  options.my.programs.udiskie = {
    enable = lib.mkEnableOption "udiskie";

    deviceConfig = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [];
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.udiskie];

    services.udiskie = {
      enable = true;
      automount = true;
      tray = "never";
      settings = {
        program_options = {
          file_manager = "thunar";
          terminal = "kitty --working-directory";
        };
        device_config = cfg.deviceConfig;
      };
    };
  };
}
