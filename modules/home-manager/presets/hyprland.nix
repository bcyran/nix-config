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
        hyprland.enable = true;
        waybar.enable = true;
        anyrun.enable = true;
        swaync.enable = true;
        hypridle.enable = true;
        hyprlock.enable = true;
        swww.enable = true;
        wlsunset.enable = true;
      };
    };

    services.poweralertd.enable = true;
  };
}
