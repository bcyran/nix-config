{
  my,
  inputs,
  ...
}: {
  imports = [
    my.nixosModules.default

    inputs.lanzaboote.nixosModules.lanzaboote
    inputs.disko.nixosModules.disko

    inputs.hardware.nixosModules.common-cpu-intel
    inputs.hardware.nixosModules.common-pc-ssd
    inputs.hardware.nixosModules.common-pc-laptop

    ./disks.nix
    ./hardware-configuration.nix
    ../common/bazyli.nix
  ];

  networking.hostName = "t480";

  my = {
    presets = {
      base.enable = true;
      desktop.enable = true;
      laptop.enable = true;
    };
    configurations = {
      lanzaboote.enable = true;
    };
    programs = {
      hyprland.enable = true;
      greetd.enable = true;
      btrbk.enable = true;
    };
  };

  services = {
    hardware.bolt.enable = true;
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
      };
    };
  };
}
