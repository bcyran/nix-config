{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (config.my.hardware) monitors;

  cfg = config.my.programs.kanshi;
  timewallCfg = config.my.programs.timewall;

  wallpaperSetCommand =
    if timewallCfg.enable
    then "timewall set"
    else "wallpaper";
in {
  options.my.programs.kanshi.enable = lib.mkEnableOption "kanshi";

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.kanshi
    ];

    # With UWSM, kanshi needs to be started after Hyprland.
    systemd.user.services.kanshi = {
      Install.WantedBy = lib.mkForce ["graphical-session.target"];
      Unit.After = lib.mkForce ["graphical-session.target"];
      Service = {
        Slice = lib.mkForce ["background-graphical.slice"];
        ExecCondition = "${pkgs.systemd}/lib/systemd/systemd-xdg-autostart-condition \"wlroots:sway:Hyprland\" \"\"";
        ConditionEnvironment = lib.mkForce [];
      };
    };
    services.kanshi = {
      enable = true;
      systemdTarget = "graphical-session-pre.target";
      settings = let
        monitorId = m:
          if m.idByOutput
          then m.output
          else m.description;
        monitorStatus = m:
          if m.enable
          then "enable"
          else "disable";
        monitorTransform = t:
          if t == 0
          then "normal"
          else toString (t * 90);

        monitorConfig = m: {
          criteria = monitorId m;
          status = monitorStatus m;
          mode = "${toString m.width}x${toString m.height}@${toString m.refreshRate}";
          position = "${toString m.x},${toString m.y}";
          transform = monitorTransform m.transform;
          inherit (m) scale;
        };
      in [
        {
          profile = {
            name = "docked";
            outputs = map monitorConfig monitors;
            exec = [wallpaperSetCommand];
          };
        }
        {
          profile = {
            name = "undocked";
            outputs = [
              (monitorConfig (lib.last monitors) // {status = "enable";})
            ];
            exec = [wallpaperSetCommand];
          };
        }
      ];
    };
  };
}
