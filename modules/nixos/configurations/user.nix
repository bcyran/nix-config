{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.my.configurations.user;
in {
  options.my.configurations.user.enable = mkEnableOption "user";

  config = mkIf cfg.enable {
    users = {
      users = {
        bazyli = {
          isNormalUser = true;
          description = "Bazyli Cyran";
          extraGroups = ["networkmanager" "wheel" "video"];
          shell = pkgs.fish;
          uid = 1000;
        };
      };
      groups = {
        video = {};
      };
    };
  };
}
