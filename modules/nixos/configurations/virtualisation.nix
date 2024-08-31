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

    users.users.${config.my.user.name}.extraGroups = ["libvirtd"];

    boot.extraModprobeConfig = ''
      options kvm_intel nested=1
      options kvm_intel emulate_invalid_guest_state=0
      options kvm ignore_msrs=1
    '';
  };
}
