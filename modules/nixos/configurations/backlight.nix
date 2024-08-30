{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.my.configurations.backlight;

  chgrpBin = "${pkgs.coreutils}/bin/chgrp";
  chmodBin = "${pkgs.coreutils}/bin/chmod";
in {
  options.my.configurations.backlight = {
    enable = lib.mkEnableOption "backlight";

    group = lib.mkOption {
      type = lib.types.str;
      default = "backlight";
      description = "The group that should own the backlight device";
    };
  };

  config = lib.mkIf cfg.enable {
    users.groups.${cfg.group}.members = [config.my.user.name];

    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="backlight", RUN+="${chgrpBin} ${cfg.group} /sys/class/backlight/%k/brightness"
      ACTION=="add", SUBSYSTEM=="backlight", RUN+="${chmodBin} g+w /sys/class/backlight/%k/brightness"
      ACTION=="add", SUBSYSTEM=="leds", RUN+="${chgrpBin} ${cfg.group} /sys/class/leds/%k/brightness"
      ACTION=="add", SUBSYSTEM=="leds", RUN+="${chmodBin} g+w /sys/class/leds/%k/brightness"
    '';
  };
}
