{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    e2fsprogs
    lsof
    lm_sensors
    curl
    usbutils
    pciutils
  ];
}
