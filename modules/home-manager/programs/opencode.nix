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
        theme = "tokyonight";
        autoupdate = false;
      };
    };
  };
}
