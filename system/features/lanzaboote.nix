{lib, ...}: {
  boot = {
    initrd.systemd.enable = true;
    loader.systemd-boot.enable = lib.mkForce false;
    bootspec.enable = true;
    lanzaboote = {
      enable = true;
      pkiBundle = "/etc/secureboot";
    };
  };
}
