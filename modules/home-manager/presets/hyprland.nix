{
  pkgs,
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
        waybar.enable = mkDefault true;
        anyrun.enable = mkDefault true;
        swaync.enable = mkDefault true;
        hypridle.enable = mkDefault true;
        hyprlock.enable = mkDefault true;
        hyprpaper.enable = mkDefault true;
        wlsunset.enable = mkDefault true;
        kanshi.enable = mkDefault true;
      };
    };

    services = {
      poweralertd.enable = mkDefault true;
      network-manager-applet.enable = mkDefault true;
    };

    home.packages = with pkgs; [
      file-roller
      gnome-calculator
      gnome-font-viewer
    ];
  };
}
