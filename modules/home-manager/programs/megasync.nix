{
  config,
  lib,
  ...
}: let
  cfg = config.my.programs.megasync;
in {
  options.my.programs.megasync.enable = lib.mkEnableOption "megasync";

  config = lib.mkIf cfg.enable {
    services.megasync.enable = true;
    systemd.user.services.megasync.Unit = {
      Requires = ["tray.target"];
      After = ["tray.target"];
    };
  };
}
