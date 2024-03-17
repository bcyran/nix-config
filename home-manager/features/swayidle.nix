{
  pkgs,
  config,
  ...
}: let
  # scripts = import ./scripts/scripts.nix {inherit pkgs;};
  # backlight = "${scripts.backlight}/bin/backlight";
  hyprctl = "${pkgs.hyprland}/bin/hyprctl";
  light = "${pkgs.light}/bin/light";
  swaylock = "${config.programs.swaylock.package}/bin/swaylock";
in {
  services.swayidle = {
    enable = true;
    extraArgs = ["-d"];
    timeouts = [
      # FIXME: Why does `backlight` doesn't work here?
      # {
      #   timeout = 5 * 60;
      #   command = "${backlight} set 10";
      #   resumeCommand = "${backlight} set 100";
      # }
      {
        timeout = 5 * 60;
        command = "${light} -S 10";
        resumeCommand = "${light} -S 100";
      }
      {
        timeout = 15 * 60;
        command = "${hyprctl} dispatch dpms off";
        resumeCommand = "${hyprctl} dispatch dpms on";
      }
      {
        timeout = 30 * 60;
        command = swaylock;
      }
    ];
  };
}
