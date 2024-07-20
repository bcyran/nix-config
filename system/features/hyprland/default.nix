{pkgs, ...}: let
  xdph = pkgs.xdg-desktop-portal-hyprland.overrideAttrs (finalAttrs: previousAttrs: {
    patches = previousAttrs.patches ++ [./xdph-service.patch];
  });
in {
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
}
