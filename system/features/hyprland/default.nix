{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.my.programs.hyprland;

  xdph = pkgs.xdg-desktop-portal-hyprland.overrideAttrs (finalAttrs: previousAttrs: {
    patches = [./xdph-service.patch];
  });
in {
  options.my.programs.hyprland.enable = mkEnableOption "hyprland";

  config = mkIf cfg.enable {
    programs.hyprland = {
      enable = true;
      portalPackage = xdph;
    };
    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      config = {
        common.default = ["gtk"];
        hyprland.default = ["gtk" "hyprland"];
      };
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
      ];
    };
  };
}
