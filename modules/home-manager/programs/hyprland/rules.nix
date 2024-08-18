{
  config,
  lib,
  ...
}: let
  cfg = config.my.programs.hyprland;
in {
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = {
      windowrulev2 = [
        # Workspace placement
        "workspace 2 silent, class:terminal-workspace"
        "workspace 10 silent, class:Spotify"
        "workspace 8 silent, class:Signal"

        # Various float, size, position tweaks
        "float, class:terminal-floating"
        "float, title:Postęp działań na plikach"
        "size 800 500, class:terminal-floating"
        "float, class:KeePassXC"
        "size 1000 700, class:KeePassXC"
        "center, class:KeePassXC"
        "float, class:gnome.Calculator"
        "float, class:MEGAsync"
        "move 100%-420 70, class:MEGAsync"
        "float, title:PhilipsTV GUI"
        "size 250 700, title:PhilipsTV GUI"
        "move 100%-270 70, title:PhilipsTV GUI"
        "size 400 760, class:protonvpn"
        "move 100%-420 70, class:protonvpn"
        "float, title:Microsoft Teams Notification"
        "float, title:splash"
        "float, title:Android Emulator"
        "noblur, class:Rofi"

        # Onagre launcher
        "noborder, class:onagre"
        "noanim, class:onagre"
        "rounding 5, class:onagre"
        "opacity 0.9, class:onagre"

        # Mattermost call widget
        "pin, title:Calls Widget"
        "float, title:Calls Widget"
        "move 100%-292 100%-116, title:Calls Widget"
        "monitor $monitorC, title:Calls Widget"
        "noborder, title:Calls Widget"
        "noshadow, title:Calls Widget"
      ];
    };
  };
}
