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

  networking = {
    hostName = "vps";
    interfaces.ens3.ipv6.addresses = [
      {
        address = "2a03:4000:52:499::1";
        prefixLength = 64;
      }
    ];
    defaultGateway6 = {
      address = "fe80::1";
      interface = "ens3";
    };
  };

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
        authorizedKeys = with my.lib.const.sshKeys; [
          bazyliAtSlimbook
          bazyliAtPixel
        ];
      };
      sops.enable = true;
    };
    services = {
      openssh.enable = true;
    };
  };

  nix.settings = {
    trusted-public-keys = [
      my.lib.const.binaryCacheKeys.intra
    ];
    substituters = [
      "https://cache.${my.lib.const.domains.intra}"
    ];
  };

  services.qemuGuest.enable = true;
  boot = {
    initrd.systemd.enable = true;
    loader.systemd-boot.enable = true;
  };
}
