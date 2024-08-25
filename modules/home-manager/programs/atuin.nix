{
  config,
  lib,
  ...
}: let
  cfg = config.my.programs.atuin;
in {
  options.my.programs.atuin.enable = lib.mkEnableOption "atuin";

  config = lib.mkIf cfg.enable {
    programs.atuin = {
      enable = true;
      flags = [
        "--disable-up-arrow"
        "--disable-ctrl-r"
      ];
      settings = {
        inline_height = 15;
        ctrl_n_shortcuts = true;
        enter_accept = true;
      };
    };
  };
}
