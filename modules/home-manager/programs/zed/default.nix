{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.programs.zed;
in {
  options.my.programs.zed.enable = lib.mkEnableOption "zed";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      zed-editor
    ];

    xdg.configFile = {
      "zed/settings.json".source = ./files/settings.json;
      "zed/keymap.json".source = ./files/keymap.json;
    };
  };
}
