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

    inputs.hardware.nixosModules.common-cpu-intel
    inputs.hardware.nixosModules.common-pc-ssd
    inputs.hardware.nixosModules.common-pc-laptop

    ./disks.nix
    ./hardware-configuration.nix
    ../common/user.nix
    ./homepage.nix
    ./services.nix
    ./backup.nix
    ./wireguard.nix
  ];

  networking = {
    hostName = "homelab";
    nameservers = ["127.0.0.1"];
  };

  sops = let
    wifiSopsFile = "${inputs.my-secrets}/wifi.yaml";
    homelabSopsFile = "${inputs.my-secrets}/homelab.yaml";
  in {
    defaultSopsFile = homelabSopsFile;
    secrets = {
      bazyli_hashed_password.neededForUsers = true;
      root_hashed_password.neededForUsers = true;
      home_wifi_env_file.sopsFile = wifiSopsFile;
      mobile_wifi_env_file.sopsFile = wifiSopsFile;
      nix_extra_options = {};
      fast_store_key_file = {};
      slow_store_key_file = {};
    };
  };

  my = {
    presets = {
      base.enable = true;
      laptopServer.enable = true;
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

  services.hardware.bolt.enable = true;

  networking.networkmanager.ensureProfiles = {
    environmentFiles = with config.sops.secrets; [
      home_wifi_env_file.path
      mobile_wifi_env_file.path
    ];
    profiles = {
      home = my.lib.nm.mkWifiProfile {
        id = "home";
        ssid = "$HOME_WIFI_SSID";
        psk = "$HOME_WIFI_PSK";
      };
      mobile = my.lib.nm.mkWifiProfile {
        id = "mobile";
        ssid = "$MOBILE_WIFI_SSID";
        psk = "$MOBILE_WIFI_PSK";
      };
    };
  };

  environment.etc."crypttab".text = ''
    fast_store /dev/disk/by-uuid/e028f76b-e2a1-4a92-89a5-2fc5aeac615b ${config.sops.secrets.fast_store_key_file.path} nofail
    slow_store /dev/disk/by-uuid/2239806d-81ac-42dc-902e-1bfd4f8e3332 ${config.sops.secrets.slow_store_key_file.path} nofail
  '';
  fileSystems = let
    inherit (my.lib.const.paths.homelab) fastStore slowStore;
  in {
    ${fastStore} = {
      device = "/dev/mapper/fast_store";
      fsType = "btrfs";
      options = ["nofail"];
    };
    ${slowStore} = {
      device = "/dev/mapper/slow_store";
      fsType = "btrfs";
      options = ["nofail"];
    };
  };
}
