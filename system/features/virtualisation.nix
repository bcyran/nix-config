{pkgs, ...}: {
  environment.systemPackages = [pkgs.qemu];
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
}
