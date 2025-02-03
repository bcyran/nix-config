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
    ./wireguard.nix
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
      btrbk_ssh_key.owner = "btrbk";
      home_wifi_env_file.sopsFile = wifiSopsFile;
      mobile_wifi_env_file.sopsFile = wifiSopsFile;
    };
  };

  my = {
    presets = {
      base.enable = true;
      laptop.enable = true;
      desktop.enable = true;
      hyprland.enable = true;
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
    services = {
      openssh.enable = true;
    };
    services = {
      tailscale.enable = true;
    };
  };

  services.hardware.bolt.enable = true;

  services.btrbk.instances.home = let
    snapshotRetention = "14d";
    snapshotRetentionMin = "3d";
  in {
    onCalendar = "hourly";
    settings = {
      volume."/" = {
        subvolume = "/home";
        snapshot_dir = "/.snapshots";
        target = "ssh://intra.cyran.dev/mnt/backup/slimbook";
        ssh_user = "btrbk";
        ssh_identity = config.sops.secrets.btrbk_ssh_key.path;
        target_preserve = snapshotRetention;
        target_preserve_min = snapshotRetentionMin;
      };
      snapshot_preserve = snapshotRetention;
      snapshot_preserve_min = snapshotRetentionMin;
      archive_preserve = snapshotRetention;
      archive_preserve_min = snapshotRetentionMin;
    };
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
