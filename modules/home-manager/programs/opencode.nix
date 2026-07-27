{
  config,
  lib,
  ...
}: let
  cfg = config.my.programs.opencode;
in {
  options.my.programs.opencode.enable = lib.mkEnableOption "opencode";

  config = lib.mkIf cfg.enable {
    programs.opencode = {
      enable = true;
      settings = {
        autoupdate = false;
        plugin = ["superpowers@git+https://github.com/obra/superpowers.git"];
      };
      tui = {
        theme = "tokyonight";
      };
    };
  };
}
