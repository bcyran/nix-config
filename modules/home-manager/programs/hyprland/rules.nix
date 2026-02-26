{
  config,
  lib,
  ...
}: let
  cfg = config.my.programs.hyprland;
in {
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = {
      windowrule = [
        "match:class terminal-floating, float on"
        "match:class terminal-floating, size 800 500"
        "match:class terminal-workspace, workspace 2 silent"

        "match:title PhilipsTV GUI, float on"
        "match:class PhilipsTV GUI, monitor $monitorC"
        "match:title PhilipsTV GUI, size 250 700"
        "match:title PhilipsTV GUI, move 100%-270 70"

        "match:class org.keepassxc.KeePassXC, float on"
        "match:class org.keepassxc.KeePassXC, monitor $monitorC"
        "match:class org.keepassxc.KeePassXC, size 1000 700"
        "match:class org.keepassxc.KeePassXC, center on"

        "match:class protonvpn, float on"
        "match:class protonvpn, monitor $monitorC"
        "match:class protonvpn, size 400 760"
        "match:class protonvpn, move 100%-420 70"

        "match:title splash, float on"
        "match:title Android Emulator, float on"

        "match:class org.gnome.Calculator, float on"
        "match:class org.gnome.Calculator, size 400 500"
        "match:class org.gnome.Calculator, move 100%-420 100%-520"

        "match:class Spotify, workspace 11 silent"
        "match:title Spotify Premium, workspace 11 silent"
        "match:class Signal, workspace 9 silent"
        "match:class signal, workspace 9 silent"
        "match:title Postęp działań na plikach, float on"
      ];
      layerrule = [
        "match:namespace anyrun, no_anim on"
      ];
    };
  };
}
