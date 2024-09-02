{
  inputs,
  my,
  config,
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

  networking.hostName = "slimbook";

  sops.secrets = {
    hashed_password = {
      sopsFile = "${inputs.my-secrets}/bazyli.yaml";
      neededForUsers = true;
    };
    root_hashed_password = {
      sopsFile = "${inputs.my-secrets}/slimbook.yaml";
      neededForUsers = true;
    };
  };

  my = {
    presets = {
      base.enable = true;
      desktop.enable = true;
      laptop.enable = true;
    };
    configurations = {
      users = {
        enable = true;
        hashedPasswordFile = config.sops.secrets.hashed_password.path;
        rootHashedPasswordFile = config.sops.secrets.root_hashed_password.path;
      };
      lanzaboote.enable = true;
      sops.enable = true;
      printing.enable = true;
      virtualisation.enable = true;
    };
    programs = {
      hyprland.enable = true;
      greetd.enable = true;
      btrbk.enable = true;
      openssh.enable = true;
    };
  };

  services = {
    hardware.bolt.enable = true;
  };

  boot.tmp.useTmpfs = true;
}
