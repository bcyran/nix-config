{
  my,
  inputs,
  config,
  ...
}: {
  imports = [
    my.nixosModules.default

    inputs.lanzaboote.nixosModules.lanzaboote
    inputs.disko.nixosModules.disko

    ./disks.nix
    ./hardware-configuration.nix
    ../common/user.nix
    ./wireguard.nix
    ./services.nix
  ];

  networking.hostName = "vps";

  sops = let
    vpsSopsFile = "${inputs.my-secrets}/vps.yaml";
  in {
    defaultSopsFile = vpsSopsFile;
    secrets = {
      bazyli_hashed_password.neededForUsers = true;
      root_hashed_password.neededForUsers = true;
      nix_extra_options = {};
    };
  };

  my = {
    presets = {
      base.enable = true;
    };
    configurations = {
      core = {
        enable = true;
        nixExtraOptionsFile = config.sops.secrets.nix_extra_options.path;
      };
      users = {
        enable = true;
        hashedPasswordFile = config.sops.secrets.bazyli_hashed_password.path;
        rootHashedPasswordFile = config.sops.secrets.root_hashed_password.path;
        authorizedKeys = [my.lib.const.sshKeys.bazyliAtSlimbook];
      };
      sops.enable = true;
    };
    services = {
      openssh.enable = true;
    };
  };

  services.qemuGuest.enable = true;
  boot = {
    initrd.systemd.enable = true;
    loader.systemd-boot.enable = true;
  };
}
