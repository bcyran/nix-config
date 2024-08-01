{
  services.btrbk.instances = {
    home = {
      onCalendar = "hourly";
      settings = {
        volume."/" = {
          subvolume = "/home";
          snapshot_dir = "/.snapshots";
        };
        snapshot_preserve = "7d";
        snapshot_preserve_min = "2d";
        archive_preserve = "7d";
        archive_preserve_min = "2d";
      };
    };
  };
}
