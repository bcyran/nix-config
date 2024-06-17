{
  systemd.user = {
    enable = true;
    # This makes the tray.target stop when logging out and start again when logging in.
    # It's important because otherwise it's constantly active and thus services relying on it
    # don't start in proper sequence when logging out and logging in again.
    targets.tray.Unit.StopWhenUnneeded = true;
  };
}
