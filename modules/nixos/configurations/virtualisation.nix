{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.my.configurations.virtualisation;
in {
  options.my.configurations.virtualisation.enable = lib.mkEnableOption "virtualisation";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [pkgs.qemu];
    virtualisation.libvirtd.enable = true;
    programs.virt-manager.enable = true;
  };
}
