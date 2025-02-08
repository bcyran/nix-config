{
  config,
  my,
  ...
}: let
  homelabDomain = my.lib.const.domains.homelab;
in {
  sops.secrets = {
    hass_secrets_file = {
      path = "${config.services.home-assistant.configDir}/secrets.yaml";
      owner = "hass";
      restartUnits = ["home-assistant.service"];
    };
    caddy_env_file = {
      owner = config.services.caddy.user;
      reloadUnits = ["caddy.service"];
    };
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
        ${homelabDomain} = my.lib.const.lan.devices.homelab.ip;
      };
    };
    caddy = {
      enable = true;
      address = "0.0.0.0";
      openFirewall = true;
      environmentFile = config.sops.secrets.caddy_env_file.path;
      extraConfig = ''
        *.intra.cyran.dev {
          tls {
            dns ovh {
              endpoint {$OVH_CYRAN_DEV_ENDPOINT}
              application_key {$OVH_CYRAN_DEV_APPLICATION_KEY}
              application_secret {$OVH_CYRAN_DEV_APPLICATION_SECRET}
              consumer_key {$OVH_CYRAN_DEV_CONSUMER_KEY}
            }
          }
        }
      '';
    };
    prometheus = {
      enable = true;
      domain = "prometheus.${homelabDomain}";
    };
    loki.enable = true;
    grafana = {
      enable = true;
      domain = "grafana.${homelabDomain}";
    };
    syncthing = {
      enable = true;
      openFirewallTransfer = true;
      domain = "syncthing.${homelabDomain}";
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
      domain = "home.${homelabDomain}";
    };
    home-assistant = {
      enable = true;
      domain = "hass.${homelabDomain}";
    };
    uptime-kuma = {
      enable = true;
      domain = "uptime.${homelabDomain}";
    };
    speedtest-tracker = {
      enable = true;
      environmentFiles = [config.sops.secrets.speedtest_tracker_env_file.path];
      domain = "speedtest.${homelabDomain}";
    };
    glances = {
      enable = true;
      domain = "glances.${homelabDomain}";
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
      domain = "hoarder.${homelabDomain}";
    };
    ollama = {
      enable = true;
      domain = "ollama.${homelabDomain}";
    };
    open-webui = {
      enable = true;
      domain = "openwebui.${homelabDomain}";
    };
    iperf = {
      enable = true;
      address = "0.0.0.0";
      openFirewall = true;
    };
    memos = {
      enable = true;
      domain = "memos.${homelabDomain}";
    };
    immich = {
      enable = true;
      domain = "immich.${homelabDomain}";
    };
    forgejo = {
      enable = true;
      domain = "forgejo.${homelabDomain}";
    };
    ntfy = {
      enable = true;
      domain = "ntfy.${homelabDomain}";
    };
    joplin = {
      enable = true;
      domain = "joplin.${homelabDomain}";
    };
    transmission = {
      enable = true;
      domain = "transmission.${homelabDomain}";
      credentialsFile = config.sops.secrets.transmission_credentials_file.path;
    };
  };

  services.btrbk.sshAccess = [
    {
      key = my.lib.const.sshKeys.btrbkAtSlimbook;
      roles = ["info" "source" "target" "delete"];
    }
  ];
}
