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
  ];

  networking.hostName = "t480";

  sops = let
    t480SopsFile = "${inputs.my-secrets}/t480.yaml";
    wifiSopsFile = "${inputs.my-secrets}/wifi.yaml";
    homelabSopsFile = "${inputs.my-secrets}/homelab.yaml";
  in {
    defaultSopsFile = t480SopsFile;
    secrets = {
      bazyli_hashed_password.neededForUsers = true;
      root_hashed_password.neededForUsers = true;
      nix_extra_options = {};
      home_wifi_env_file.sopsFile = wifiSopsFile;
      mobile_wifi_env_file.sopsFile = wifiSopsFile;
      ovh_api_env_file.sopsFile = homelabSopsFile;
      tailscale_auth_key.sopsFile = homelabSopsFile;
      syncthing_key_file.sopsFile = homelabSopsFile;
      syncthing_cert_file.sopsFile = homelabSopsFile;
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
    };
    services = let
      intraDomain = "intra.cyran.dev";
      intraIP = "192.168.0.130";
    in {
      blocky = {
        enable = true;
        customDNSMappings = {
          ${intraDomain} = intraIP;
        };
      };
      caddy = {
        enable = true;
        environmentFiles = [config.sops.secrets.ovh_api_env_file.path];
      };
      prometheus = {
        enable = true;
        domain = "prometheus.${intraDomain}";
      };
      loki.enable = true;
      grafana = {
        enable = true;
        domain = "grafana.${intraDomain}";
      };
      tailscale = {
        enable = true;
        advertiseRoutes = ["${intraIP}/32"];
        authKeyFile = config.sops.secrets.tailscale_auth_key.path;
      };
      syncthing = {
        enable = true;
        domain = "syncthing.${intraDomain}";
        keyFile = config.sops.secrets.syncthing_key_file.path;
        certFile = config.sops.secrets.syncthing_cert_file.path;
        devices = {
          slimbook = "ADH7KVP-ATNX6XY-VSBFKEW-U7A4TAI-2YA6JQG-DZHNGRR-2DZOIXW-KAS6AQX";
          pixel7 = "WCA3ZM5-ZELYQWF-VAWS425-OPG5Q4R-O4J3ARM-IOPGI7Z-BTE2TY5-EZ36AAI";
          srv = "K755SJE-WJVQQNY-M3RSJP7-RYLNIOF-TJNMR3H-32WAY53-KPX5BFM-5RZSRQL";
        };
        folders = ["KeePass" "Portfolio" "Signal backup" "Sync"];
      };
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
