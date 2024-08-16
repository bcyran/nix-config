{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.my.programs.megasync;
in {
  options.my.programs.megasync.enable = mkEnableOption "megasync";

  config = mkIf cfg.enable {
    services.megasync.enable = true;
    systemd.user.services.megasync.Unit = {
      Requires = ["tray.target"];
      After = ["tray.target"];
    };
  };
}
