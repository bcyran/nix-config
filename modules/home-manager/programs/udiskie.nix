{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.my.programs.udiskie;
in {
  options.my.programs.udiskie.enable = mkEnableOption "udiskie";

  config = mkIf cfg.enable {
    home.packages = [pkgs.udiskie];

    services.udiskie = {
      enable = true;
      automount = true;
      tray = "never";
      settings = {
        program_options = {
          file_manager = "thunar";
          terminal = "alacritty --working-directory";
        };
        device_config = [
          {
            id_uuid = "e028f76b-e2a1-4a92-89a5-2fc5aeac615b";
            keyfile = "${config.my.user.home}/.backup_key";
            automount = true;
            ignore = false;
          }
        ];
      };
    };
  };
}
