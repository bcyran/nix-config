{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkDefault;
  cfg = config.my.presets.noctalia;
in {
  options.my.presets.noctalia.enable = lib.mkEnableOption "noctalia";

  config = lib.mkIf cfg.enable {
    my.programs = {
      hyprland = {
        enable = mkDefault true;
        withNoctalia = mkDefault true;
      };
      noctalia.enable = mkDefault true;
      kanshi.enable = mkDefault true;
    };
    services = {
      poweralertd.enable = mkDefault true;
      network-manager-applet.enable = mkDefault true;
    };
    home.packages = with pkgs; [
      file-roller
      gnome-calculator
      gnome-font-viewer
      gpu-screen-recorder
    ];
  };
}
