{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.programs.timewall;

  timewallBin = "${pkgs.timewall}/bin/timewall";
  sleepBin = "${pkgs.coreutils}/bin/sleep";

  configFormat = pkgs.formats.toml {};
in {
  options.my.programs.timewall.enable = lib.mkEnableOption "timewall";

  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.timewall];

    xdg.configFile."timewall/config.toml".source = configFormat.generate "config.toml" {
      location = {
        lat = 51.11;
        lon = 17.02;
      };
      setter = {
        command = ["hyprpaperset" "%f"];
      };
    };

    systemd.user.services.timewall = {
      Unit = {
        Description = "Dynamic wallpaper daemon";
        PartOf = ["graphical-session.target"];
        After = ["hyprpaper.service"];
        Requires = ["hyprpaper.service"];
      };
      Service = {
        Type = "simple";
        ExecStartPre = "${sleepBin} 3";
        ExecStart = "${timewallBin} set --daemon";
        Restart = "on-failure";
      };
      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };
  };
}
