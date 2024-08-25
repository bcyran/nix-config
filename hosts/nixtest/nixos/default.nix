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

  networking.hostName = "nixtest";

  my = {
    configurations = {
      core.enable = true;
      user.enable = true;
      lanzaboote.enable = true;
      networking.enable = true;
      console.enable = true;
      locale.enable = true;
      bluetooth.enable = true;
      audio.enable = true;
      ddcci.enable = true;
      filesystem.enable = true;
      printing.enable = true;
      silentboot.enable = true;
      virtualisation.enable = true;
    };
    programs = {
      hyprland.enable = true;
      btrbk.enable = true;
      greetd.enable = true;
      logiops.enable = true;
      tlp.enable = true;
      upower.enable = true;
    };
  };

  services = {
    hardware.bolt.enable = true;
    systemd-lock-handler.enable = true; # Required for `lock.target` in user's systemd
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
      };
    };
  };

  security = {
    pam.services.hyprlock.text = "auth include login"; # Required by `hyprlock`
    polkit.enable = true;
  };
}
