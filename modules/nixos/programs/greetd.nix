{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.my.programs.greetd;
in {
  options.my.programs.greetd.enable = lib.mkEnableOption "greetd";

  config = lib.mkIf cfg.enable {
    programs.noctalia-greeter = {
      enable = true;
      settings = {
        user.default = config.my.user.name;
        keyboard.layout = "pl";
        session.default = "Hyprland (uwsm-managed)";
        idle.timeout = 300;
        cursor = {
          theme = "phinger-cursors-dark";
          size = 24;
          path = "${pkgs.phinger-cursors}/share/icons";
        };
      };
    };
  };
}
