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
  ];

  networking = {
    hostName = "t480";
    nameservers = ["127.0.0.1"];
  };

  sops = let
    t480SopsFile = "${inputs.my-secrets}/t480.yaml";
    wifiSopsFile = "${inputs.my-secrets}/wifi.yaml";
  in {
    defaultSopsFile = t480SopsFile;
    secrets = {
      bazyli_hashed_password.neededForUsers = true;
      root_hashed_password.neededForUsers = true;
      nix_extra_options = {};
      home_wifi_env_file.sopsFile = wifiSopsFile;
      mobile_wifi_env_file.sopsFile = wifiSopsFile;
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
      };
      lanzaboote.enable = true;
      sops.enable = true;
    };
    programs = {
      btrbk.enable = true;
      openssh.enable = true;
      podman.enable = true;
    };
  };

  services = {
    hardware.bolt.enable = true;
  };

  networking.networkmanager.ensureProfiles = {
    environmentFiles = with config.sops.secrets; [
      home_wifi_env_file.path
      mobile_wifi_env_file.path
    ];
    profiles = {
      home = my.lib.makeNetworkManagerWifiProfile {
        id = "home";
        ssid = "$HOME_WIFI_SSID";
        psk = "$HOME_WIFI_PSK";
      };
      mobile = my.lib.makeNetworkManagerWifiProfile {
        id = "mobile";
        ssid = "$MOBILE_WIFI_SSID";
        psk = "$MOBILE_WIFI_PSK";
      };
    };
  };
}
