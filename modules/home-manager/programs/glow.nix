{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.my.programs.glow;
in {
  options.my.programs.glow.enable = lib.mkEnableOption "glow";

  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.glow];

    xdg.configFile."glow/glow.yml".text = ''
      pager: true
      width: 100
    '';
  };
}
