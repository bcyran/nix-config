{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.my.programs.hyprland;
in {
  options.my.programs.hyprland.enable = lib.mkEnableOption "hyprland";

  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      systemd = {
        enable = true;
        enableXdgAutostart = true;
        variables = ["--all"];
      };
    };

    programs.hyprcursor-phinger.enable = true;
    home = {
      packages = [pkgs.hyprcursor];
      sessionVariables = {
        NIXOS_OZONE_WL = "1";
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
