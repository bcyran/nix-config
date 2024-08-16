{
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
  };

  imports = [
    ./binds.nix
    ./settings.nix
    ./rules.nix
  ];
}
