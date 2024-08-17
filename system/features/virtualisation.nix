{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.my.configurations.virtualisation;
in {
  options.my.configurations.virtualisation.enable = mkEnableOption "virtualisation";

  config = mkIf cfg.enable {
    environment.systemPackages = [pkgs.qemu];
    virtualisation.libvirtd.enable = true;
    programs.virt-manager.enable = true;
  };
}
