{
  config,
  lib,
  ...
}: let
  cfg = config.my.programs.gh;
in {
  options.my.programs.gh.enable = lib.mkEnableOption "gh";

  config = lib.mkIf cfg.enable {
    programs.gh = {
      enable = true;
      settings = {
        git_protocol = "ssh";
      };
    };
  };
}
