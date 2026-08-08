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
        plugin = [
          "superpowers@git+https://github.com/obra/superpowers.git"
          "opencode-rules@git+https://github.com/frap129/opencode-rules.git"
        ];
      };
      tui = {
        theme = "tokyonight";
      };
    };
  };
}
