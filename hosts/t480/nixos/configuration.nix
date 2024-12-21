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
    };
  };

  # Server-specific
  # Disable the screen after 2 minutes of inactivity
  boot.kernelParams = [
    "consoleblank=120"
  ];
  # Disable the lid switch completely
  services.logind = {
    lidSwitch = "ignore";
    lidSwitchExternalPower = "ignore";
    lidSwitchDocked = "ignore";
  };
  # Disable the suspend target completely
  systemd.targets.sleep.enable = false;

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
      grafana = {
        enable = true;
        domain = "grafana.${intraDomain}";
      };
      tailscale = {
        enable = true;
        advertiseRoutes = ["${intraIP}/32"];
        authKeyFile = config.sops.secrets.tailscale_auth_key.path;
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
