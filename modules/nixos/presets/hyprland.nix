{
  config,
  lib,
  ...
}: let
  inherit (lib) mkDefault;
  cfg = config.my.presets.hyprland;
in {
  options.my.presets.hyprland.enable = lib.mkEnableOption "hyprland";

  config = lib.mkIf cfg.enable {
    my = {
      programs = {
        hyprland.enable = mkDefault true;
        greetd.enable = mkDefault true;
      };
    };

    security = {
      pam.services.hyprlock.text = "auth include login"; # Required by `hyprlock`
    };
  };
}
