{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.my.programs.hyprland;
in {
  options.my.programs.hyprland.enable = mkEnableOption "hyprland";

  config = mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      systemd = {
        enable = true;
        enableXdgAutostart = true;
      };
    };

    programs.hyprcursor-phinger.enable = true;
    home = {
      packages = [pkgs.hyprcursor];
      sessionVariables = {
        HYPRCURSOR_THEME = "phinger-cursors-dark-hyprcursor";
        HYPRCURSOR_SIZE = "24";
      };
    };
  };

  imports = [
    ./binds.nix
    ./settings.nix
    ./rules.nix
  ];
}
