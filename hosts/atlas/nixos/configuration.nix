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

    inputs.hardware.nixosModules.common-cpu-amd
    inputs.hardware.nixosModules.common-cpu-amd-pstate
    inputs.hardware.nixosModules.common-cpu-amd-raphael-igpu
    inputs.hardware.nixosModules.common-pc-ssd

    ./disks.nix
    ./hardware-configuration.nix
    ../common/user.nix
    ./homepage.nix
  ];

  # TODO: Move to services module
  my.services.openssh.enable = true;

  networking = {
    hostName = "atlas";
    hostID = "07eb2678";
    nameservers = ["127.0.0.1"];
  };

  sops = let
    homelabSopsFile = "${inputs.my-secrets}/homelab.yaml";
  in {
    defaultSopsFile = homelabSopsFile;
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
        # nixExtraOptionsFile = config.sops.secrets.nix_extra_options.path;
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
      lanzaboote.enable = true;
      sops.enable = true;
    };
    programs = {
      podman.enable = true;
    };
  };

  nix.settings = {
    trusted-public-keys = [
      my.lib.const.binaryCacheKeys.slimbook
    ];
  };
}
