{
  config,
  my,
  lib,
  ...
}: let
  intraDomain = my.lib.const.domains.intra;

  getDeviceIps = device:
    my.lib.filterNotNull [device.ip (my.lib.getAttrOrNull "ipv6" device)];
  mkDnsMappingItem = device: {
    ${device.domain} = builtins.concatStringsSep "," (getDeviceIps device);
  };
  mkDnsMapping = attrs:
    lib.mergeAttrsList
    (map mkDnsMappingItem (builtins.attrValues attrs));
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
      customDNSMappings =
        {${intraDomain} = my.lib.const.lan.devices.homelab.ip;}
        // mkDnsMapping my.lib.const.lan.devices
        // mkDnsMapping my.lib.const.wireguard.peers;
    };
    caddy = {
      enable = true;
      address = "0.0.0.0";
      openFirewall = true;
      environmentFile = config.sops.secrets.caddy_env_file.path;
      reverseProxyHostsCommonExtraConfig = ''
        tls {
          resolvers ${lib.concatStringsSep " " my.lib.const.dns.ips};
          dns ovh {
            endpoint {$OVH_CYRAN_DEV_ENDPOINT}
            application_key {$OVH_CYRAN_DEV_APPLICATION_KEY}
            application_secret {$OVH_CYRAN_DEV_APPLICATION_SECRET}
            consumer_key {$OVH_CYRAN_DEV_CONSUMER_KEY}
          }
        }
      '';
    };
    prometheus = {
      enable = true;
      reverseProxy.domain = "prometheus.${intraDomain}";
    };
    loki.enable = true;
    grafana = {
      enable = true;
      reverseProxy.domain = "grafana.${intraDomain}";
    };
    syncthing = {
      enable = true;
      openFirewallTransfer = true;
      reverseProxy.domain = "syncthing.${intraDomain}";
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
      reverseProxy.domain = "home.${intraDomain}";
    };
    home-assistant = {
      enable = true;
      reverseProxy.domain = "hass.${intraDomain}";
    };
    uptime-kuma = {
      enable = true;
      reverseProxy.domain = "uptime.${intraDomain}";
    };
    speedtest-tracker = {
      enable = true;
      environmentFiles = [config.sops.secrets.speedtest_tracker_env_file.path];
      reverseProxy.domain = "speedtest.${intraDomain}";
    };
    glances = {
      enable = true;
      reverseProxy.domain = "glances.${intraDomain}";
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
      reverseProxy.domain = "hoarder.${intraDomain}";
    };
    ollama = {
      enable = true;
      reverseProxy.domain = "ollama.${intraDomain}";
    };
    open-webui = {
      enable = true;
      reverseProxy.domain = "openwebui.${intraDomain}";
    };
    iperf = {
      enable = true;
      address = "0.0.0.0";
      openFirewall = true;
    };
    memos = {
      enable = true;
      reverseProxy.domain = "memos.${intraDomain}";
    };
    immich = {
      enable = true;
      reverseProxy.domain = "immich.${intraDomain}";
    };
    forgejo = {
      enable = true;
      reverseProxy.domain = "forgejo.${intraDomain}";
    };
    ntfy = {
      enable = true;
      reverseProxy.domain = "ntfy.${intraDomain}";
    };
    joplin = {
      enable = true;
      reverseProxy.domain = "joplin.${intraDomain}";
    };
    transmission = {
      enable = true;
      reverseProxy.domain = "transmission.${intraDomain}";
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
