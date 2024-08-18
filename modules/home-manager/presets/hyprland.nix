{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.my.presets.hyprland;
in {
  options.my.presets.hyprland.enable = mkEnableOption "hyprland";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      file-roller
      gnome-calculator
      gnome-font-viewer
    ];

    my = {
      programs = {
        hyprland.enable = mkDefault true;
        waybar.enable = mkDefault true;
        anyrun.enable = mkDefault true;
        swaync.enable = mkDefault true;
        hypridle.enable = mkDefault true;
        hyprlock.enable = mkDefault true;
        swww.enable = mkDefault true;
        wlsunset.enable = mkDefault true;
      };
    };

    services.poweralertd.enable = mkDefault true;
  };
}
