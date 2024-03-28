{
  pkgs,
  config,
  ...
}: let
  backlight = "${pkgs.my.backlight}/bin/backlight";
  hyprctl = "${pkgs.hyprland}/bin/hyprctl";
  # swaylock = "${config.programs.swaylock.package}/bin/swaylock";
in {
  services.swayidle = {
    enable = true;
    extraArgs = ["-d"];
    timeouts = [
      {
        timeout = 5 * 60;
        command = "${backlight} set 10";
        resumeCommand = "${backlight} set 100";
      }
      {
        timeout = 15 * 60;
        command = "${hyprctl} dispatch dpms off";
        resumeCommand = "${hyprctl} dispatch dpms on";
      }
      # FIXME: Figure out why it's impossible to unlock screen if it's locked after DPMS off
      # {
      #   timeout = 30 * 60;
      #   command = "${swaylock} -f";
      # }
    ];
  };
}
