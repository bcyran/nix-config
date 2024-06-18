{
  wayland.windowManager.hyprland = {
    enable = true;
    systemd = {
      enable = true;
      enableXdgAutostart = true;
    };
  };
  imports = [
    ./binds.nix
    ./settings.nix
    ./rules.nix
  ];
}
