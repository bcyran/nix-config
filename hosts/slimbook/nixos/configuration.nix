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
    ../common/user.nix
  ];

  networking.hostName = "slimbook";

  sops = let
    slimbookSopsFile = "${inputs.my-secrets}/slimbook.yaml";
    wifiSopsFile = "${inputs.my-secrets}/wifi.yaml";
  in {
    defaultSopsFile = slimbookSopsFile;
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
      desktop.enable = true;
      laptop.enable = true;
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
