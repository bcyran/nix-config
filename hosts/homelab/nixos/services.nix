{config, ...}: let
  intraIP = "10.100.100.100";
  intraDomain = "intra.cyran.dev";
in {
  sops.secrets = {
    hass_secrets_file = {
      path = "${config.services.home-assistant.configDir}/secrets.yaml";
      owner = "hass";
      restartUnits = ["home-assistant.service"];
    };
    ovh_api_env_file = {};
    tailscale_auth_key = {};
    syncthing_key_file = {};
    syncthing_cert_file = {};
    syncthing_env_file = {};
    homepage_env_file = {};
    speedtest_tracker_env_file = {};
    meilisearch_env_file = {};
    hoarder_env_file = {};
    transmission_credentials_file = {};
    wireguard_conf_file = {};
  };

  my.configurations = {
    vpnConfinement = {
      enable = true;
      wireguardConfigFile = config.sops.secrets.wireguard_conf_file.path;
      namespaceName = "proton";
    };
  };

  my.services = {
    openssh.enable = true;
    blocky = {
      enable = true;
      dnsAddress = "0.0.0.0";
      openFirewall = true;
      customDNSMappings = {
        ${intraDomain} = intraIP;
      };
    };
    caddy = {
      enable = true;
      address = "0.0.0.0";
      openFirewall = true;
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
      openFirewallTransfer = true;
      domain = "syncthing.${intraDomain}";
      keyFile = config.sops.secrets.syncthing_key_file.path;
      certFile = config.sops.secrets.syncthing_cert_file.path;
      environmentFiles = [config.sops.secrets.syncthing_env_file.path];
      devices = {
        slimbook = "ADH7KVP-ATNX6XY-VSBFKEW-U7A4TAI-2YA6JQG-DZHNGRR-2DZOIXW-KAS6AQX";
        pixel7 = "WCA3ZM5-ZELYQWF-VAWS425-OPG5Q4R-O4J3ARM-IOPGI7Z-BTE2TY5-EZ36AAI";
        srv = "K755SJE-WJVQQNY-M3RSJP7-RYLNIOF-TJNMR3H-32WAY53-KPX5BFM-5RZSRQL";
      };
      folders = ["KeePass" "Portfolio" "Signal backup" "Sync"];
      hashedPassword = "$2a$12$16cl3sRqqpClYhSn/Q1rsuA2gsPI0sYPEk6Zs8QTU5oWwlAY0Y8wC";
    };
    homepage = {
      enable = true;
      environmentFile = config.sops.secrets.homepage_env_file.path;
      domain = "home.${intraDomain}";
    };
    home-assistant = {
      enable = true;
      domain = "hass.${intraDomain}";
    };
    uptime-kuma = {
      enable = true;
      domain = "uptime.${intraDomain}";
    };
    speedtest-tracker = {
      enable = true;
      environmentFiles = [config.sops.secrets.speedtest_tracker_env_file.path];
      domain = "speedtest.${intraDomain}";
    };
    glances = {
      enable = true;
      domain = "glances.${intraDomain}";
    };
    postgresql.enable = true;
    meilisearch = {
      enable = true;
      masterKeyEnvironmentFile = config.sops.secrets.meilisearch_env_file.path;
    };
    chromium = {
      enable = true;
    };
    hoarder = {
      enable = true;
      environmentFiles = with config.sops.secrets; [
        hoarder_env_file.path
        meilisearch_env_file.path
      ];
      domain = "hoarder.${intraDomain}";
    };
    ollama = {
      enable = true;
      domain = "ollama.${intraDomain}";
    };
    open-webui = {
      enable = true;
      domain = "openwebui.${intraDomain}";
    };
    iperf = {
      enable = true;
      address = "0.0.0.0";
      openFirewall = true;
    };
    memos = {
      enable = true;
      domain = "memos.${intraDomain}";
    };
    immich = {
      enable = true;
      domain = "immich.${intraDomain}";
    };
    forgejo = {
      enable = true;
      domain = "forgejo.${intraDomain}";
    };
    ntfy = {
      enable = true;
      domain = "ntfy.${intraDomain}";
    };
    joplin = {
      enable = true;
      domain = "joplin.${intraDomain}";
    };
    transmission = {
      enable = true;
      domain = "transmission.${intraDomain}";
      credentialsFile = config.sops.secrets.transmission_credentials_file.path;
    };
  };

  services.btrbk.sshAccess = [
    {
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC8a552vyvnPoS/JEkSujoygzQw0cB8jO2yI8VlsLUF6 btrbk@slimbook";
      roles = ["info" "source" "target" "delete"];
    }
  ];
}
