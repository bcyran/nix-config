{
  services.megasync.enable = true;
  systemd.user.services.megasync.Unit = {
    Requires = ["tray.target"];
    After = ["tray.target"];
  };
}
