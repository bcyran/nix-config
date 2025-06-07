{
  config,
  lib,
  ...
}: let
  inherit (lib) mkDefault;
  cfg = config.my.presets.base;
in {
  options.my.presets.base.enable = lib.mkEnableOption "base";

  config = lib.mkIf cfg.enable {
    my = {
      configurations = {
        core.enable = mkDefault true;
        users.enable = mkDefault true;
        networking.enable = mkDefault true;
        console.enable = mkDefault true;
        locale.enable = mkDefault true;
      };
      programs = {
        nh.enable = mkDefault true;
      };
    };

    programs.nix-ld.enable = mkDefault true;
  };
}
