{
  inputs,
  my,
  config,
  pkgs,
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
      nix_store_binary_cache_key = {};
      home_wifi_env_file.sopsFile = wifiSopsFile;
      mobile_wifi_env_file.sopsFile = wifiSopsFile;
      ntfy_sh_env_file = {};
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
      lanzaboote = {
        enable = true;
        pkiBundle = "/etc/secureboot";
      };
      sops.enable = true;
      printing.enable = true;
      virtualisation.enable = true;
    };
    programs = {
      adb.enable = true;
    };
    services = {
      openssh.enable = true;
      ntfy-systemd = {
        enable = true;
        serverUrl = "https://ntfy.${my.lib.const.domains.intra}";
        environmentFiles = [config.sops.secrets.ntfy_sh_env_file.path];
      };
    };
  };

  programs = {
    kdeconnect.enable = true;
  };

  environment.systemPackages = [pkgs.sshfs];
  fileSystems = let
    inherit (my.lib) const;
    userCfg = config.my.user;
    atlasDomain = const.lan.devices.atlas.domain;
    atlasPaths = const.paths.atlas;
    sshfsOptions = [
      "x-systemd.automount"
      "noauto"
      "x-systemd.idle-timeout=300"
      "x-systemd.device-timeout=5s"
      "x-systemd.mount-timeout=5s"
      "nodev"
      "noatime"
      "allow_other"
      "IdentityFile=${userCfg.home}/.ssh/id_ed25519"
    ];
  in {
    "/mnt/FastStore" = {
      device = "${userCfg.name}@${atlasDomain}:${atlasPaths.fastMisc}";
      fsType = "sshfs";
      options = sshfsOptions;
    };
    "/mnt/SlowStore" = {
      device = "${userCfg.name}@${atlasDomain}:${atlasPaths.slowMisc}";
      fsType = "sshfs";
      options = sshfsOptions;
    };
  };

  nix.settings.secret-key-files = [
    config.sops.secrets.nix_store_binary_cache_key.path
  ];

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
        ssh_user = "btrbk";
        ssh_identity = config.sops.secrets.btrbk_ssh_key.path;
      };
      snapshot_preserve = snapshotRetention;
      snapshot_preserve_min = snapshotRetentionMin;
      archive_preserve = snapshotRetention;
      archive_preserve_min = snapshotRetentionMin;
    };
  };
  systemd.services.btrbk-home.onFailure = ["ntfy-failed@btrbk-home.service"];

  boot.tmp.useTmpfs = true;

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
}
