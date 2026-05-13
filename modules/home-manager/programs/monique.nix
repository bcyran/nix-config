{
  my,
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (pkgs.stdenv.hostPlatform) system;
  moniquePkg = my.inputs.monique.packages.${system}.default;

  cfg = config.my.programs.monique;
in {
  options.my.programs.monique.enable = lib.mkEnableOption "monique";

  config = lib.mkIf cfg.enable {
    home.packages = [moniquePkg];

    systemd.user.services.moniqued = {
      Unit = {
        Description = "Monique daemon - Auto-apply monitor profiles on hotplug";
        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target"];
      };
      Service = {
        Type = "simple";
        ExecStart = lib.getExe' moniquePkg "moniqued";
        Restart = "on-failure";
        RestartSec = 5;
      };
      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };
  };
}
