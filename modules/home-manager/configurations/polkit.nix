{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.my.configurations.polkit;

  polkitAgentBin = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
in {
  options.my.configurations.polkit.enable = mkEnableOption "polkit";

  config = mkIf cfg.enable {
    systemd.user.services.polkit-gnome-authentication-agent-1 = {
      Unit = {
        Description = "PolicyKit Authentication Agent";
        PartOf = ["graphical-session.target"];
        After = ["graphical-session-pre.target"];
        StartLimitBurst = 10;
      };
      Service = {
        Type = "simple";
        ExecStart = polkitAgentBin;
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };
  };
}
