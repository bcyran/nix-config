{
  config,
  lib,
  ...
}: let
  inherit (config.my.hardware) monitors;
  cfg = config.my.programs.kanshi;
in {
  options.my.programs.kanshi.enable = lib.mkEnableOption "kanshi";

  config = lib.mkIf cfg.enable {
    services.kanshi = {
      enable = true;
      systemdTarget = "graphical-session.target";
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
          };
        }
        {
          profile = {
            name = "undocked";
            outputs = [
              (monitorConfig (lib.last monitors) // {status = "enable";})
            ];
          };
        }
      ];
    };
  };
}
