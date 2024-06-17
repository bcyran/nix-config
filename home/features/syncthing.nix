{pkgs, ...}: {
  services.syncthing = {
    enable = true;
    tray = {
      enable = true;
      # For some reason syncthingtray-minimal always starts before the tray...
      package = pkgs.syncthingtray;
    };
  };
}
