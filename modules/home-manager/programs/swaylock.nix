{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (config.colorScheme) palette;
  cfg = config.my.programs.swaylock;

  swaylockPkg = pkgs.swaylock-effects;
  swaylockBin = "${swaylockPkg}/bin/swaylock";
in {
  options.my.programs.swaylock.enable = lib.mkEnableOption "swaylock";

  config = lib.mkIf cfg.enable {
    programs.swaylock = {
      enable = true;
      package = swaylockPkg;
      settings = {
        color = "#${palette.base00}";

        font = builtins.elemAt config.fonts.fontconfig.defaultFonts.sansSerif 0;
        font-size = 50;
        clock = true;
        timestr = "%H:%M";
        datestr = "";
        indicator = true;
        indicator-idle-visible = true;
        fade-in = 1;

        text-color = "#${palette.base05}";
        inside-color = "#${palette.base00}";
        inside-ver-color = "#${palette.base00}";
        inside-wrong-color = "#${palette.base00}";
        line-uses-inside = true;
        separator-color = "#${palette.base00}";
        indicator-radius = 120;

        ring-color = "#${palette.accentPrimary}";
        ring-ver-color = "#${palette.warning}";
        ring-wrong-color = "#${palette.error}";
        key-hl-color = "#${palette.accentSecondary}";

        text-wrong-color = "#${palette.base05}";
        text-ver-color = "#${palette.base05}";
      };
    };

    # This requires `services.systemd-lock-handler.enable = true` in the system config.
    systemd.user.services.lock = {
      Unit = {
        Description = "Screen locker.";
        OnSuccess = ["unlock.target"];
        PartOf = ["lock.target"];
        After = ["lock.target"];
      };
      # Change this to forking service without custom script if hyprlock implements forking mode.
      # See: https://github.com/hyprwm/hyprlock/issues/184
      Service = {
        Type = "forking";
        NotifyAccess = "all";
        ExecStart = "${swaylockBin} -f";
        Restart = "on-failure";
        RestartSec = 0;
      };
      Install = {
        WantedBy = ["lock.target"];
      };
    };
  };
}
