{
  config,
  my,
  lib,
  ...
}: let
  intraDomain = my.lib.const.domains.intra;
  mediaGroup = "servarr";

  caddyTlsConfig = ''
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

  getDeviceIps = device:
    my.lib.filterNotNull [device.ip (my.lib.getAttrOrNull "ipv6" device)];
  mkDnsMappingItem = device: {
    name = device.domain;
    value = builtins.concatStringsSep "," (getDeviceIps device);
  };
  mkDnsMapping = attrs:
    my.lib.mapListToAttrs mkDnsMappingItem (builtins.attrValues attrs);
in {
  sops.secrets = let
    containersBackend = config.virtualisation.oci-containers.backend;
  in {
    hass_secrets_file = {
      path = "${config.services.home-assistant.configDir}/secrets.yaml";
      owner = "hass";
      restartUnits = ["home-assistant.service"];
    };
    caddy_env_file = {
      owner = config.services.caddy.user;
      reloadUnits = ["caddy.service"];
    };
    syncthing_key_file = {
      restartUnits = ["syncthing.service"];
    };
    syncthing_cert_file = {
      restartUnits = ["syncthing.service"];
    };
    syncthing_env_file = {
      restartUnits = ["syncthing.service"];
    };
    syncthing_gui_password_file = {
      owner = config.services.syncthing.user;
      restartUnits = ["syncthing.service"];
    };
    homepage_env_file = {
      restartUnits = ["homepage-dashboard.service"];
    };
    speedtest_tracker_env_file = {
      restartUnits = ["${containersBackend}-speedtest-tracker.service"];
    };
    transmission_credentials_file = {
      reloadUnits = ["transmission.service"];
    };
    airvpn_conf_file = {
      restartUnits = ["airvpn.service"];
    };
    nix_store_binary_cache_key = {
      restartUnits = ["nix-serve.service"];
    };
    nextcloud_admin_pass = {
      owner = "nextcloud";
    };
    nextcloud_whiteboard_env_file = {
      restartUnits = ["nextcloud-whiteboard-server.service"];
    };
    collabora_env_file = {
      restartUnits = ["${containersBackend}-collabora.service"];
    };
    linkwarden_env_file = {
      restartUnits = ["${containersBackend}-linkwarden.service"];
    };
    recyclarr_env_file = {
      restartUnits = ["recyclarr.service"];
    };
    pinchflat_env_file = {
      restartUnits = ["pinchflat.service"];
    };
    mqtt_hass_password_file = {};
    ntfy_sh_env_file = {};
    paperless_password_file = {};
  };

  my.configurations = {
    vpnConfinement = {
      enable = true;
      wireguardConfigFile = config.sops.secrets.airvpn_conf_file.path;
      namespaceName = "airvpn";
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
      reverseProxyHostsCommonExtraConfig = caddyTlsConfig;
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
    syncthing = let
      inherit (my.lib.const.syncthing) devices;
    in {
      enable = true;
      supplementaryGroups = [mediaGroup];
      openFirewallTransfer = true;
      reverseProxy.domain = "syncthing.${intraDomain}";
      keyFile = config.sops.secrets.syncthing_key_file.path;
      certFile = config.sops.secrets.syncthing_cert_file.path;
      environmentFiles = [config.sops.secrets.syncthing_env_file.path];
      guiPasswordFile = config.sops.secrets.syncthing_gui_password_file.path;
      inherit devices;
      folders = [
        {name = "KeePass";}
        {name = "Portfolio";}
        {name = "Sync";}
        {
          name = "Signal backup";
          devices = ["pixel7"];
        }
        {
          name = "Music YT";
          path = "${my.lib.const.paths.homelab.fastMedia}/music/youtube";
          type = "sendonly";
          devices = ["slimbook" "pixel7"];
        }
        {
          name = "Music Lidarr";
          path = "${my.lib.const.paths.homelab.fastMedia}/music/lidarr";
          type = "sendonly";
          devices = ["slimbook"];
        }
      ];
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
    mosquitto = {
      enable = true;
      address = "0.0.0.0";
      openFirewall = true;
      users = {
        hass = {
          acl = ["readwrite #"];
          passwordFile = config.sops.secrets.mqtt_hass_password_file.path;
        };
      };
    };
    uptime-kuma = {
      enable = true;
      reverseProxy.domain = "uptime.${intraDomain}";
    };
    speedtest-tracker = {
      enable = true;
      environmentFiles = [config.sops.secrets.speedtest_tracker_env_file.path];
      reverseProxy.domain = "speedtest.${intraDomain}";
      blockedServers = [
        5679 # My ISP's server, shows higher speeds than actual.
        5326 # This one always shows lower speeds than actual.
      ];
    };
    glances = {
      enable = true;
      reverseProxy.domain = "glances.${intraDomain}";
    };
    postgresql.enable = true;
    linkwarden = {
      enable = true;
      environmentFile = config.sops.secrets.linkwarden_env_file.path;
      reverseProxy.domain = "linkwarden.${intraDomain}";
      llm = "phi3";
    };
    iperf = {
      enable = true;
      address = "0.0.0.0";
      openFirewall = true;
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
    ntfy-systemd = {
      enable = true;
      serverUrl = "http://127.0.0.1:${toString config.my.services.ntfy.port}";
      environmentFiles = [config.sops.secrets.ntfy_sh_env_file.path];
    };
    joplin = {
      enable = true;
      reverseProxy.domain = "joplin.${intraDomain}";
    };
    nix-serve = {
      enable = true;
      reverseProxy.domain = "cache.${intraDomain}";
      secretKeyFile = config.sops.secrets.nix_store_binary_cache_key.path;
    };
    nextcloud = {
      enable = true;
      domain = "nextcloud.${intraDomain}";
      adminPassFile = config.sops.secrets.nextcloud_admin_pass.path;
      whiteboardEnvironmentFiles = [config.sops.secrets.nextcloud_whiteboard_env_file.path];
      caddyExtraConfig = caddyTlsConfig;
    };
    collabora = {
      enable = true;
      reverseProxy.domain = "collabora.${intraDomain}";
      environmentFiles = [config.sops.secrets.collabora_env_file.path];
    };
    drawio = {
      enable = true;
      reverseProxy.domain = "drawio.${intraDomain}";
    };
    paperless = {
      enable = true;
      reverseProxy.domain = "paperless.${intraDomain}";
      passwordFile = config.sops.secrets.paperless_password_file.path;
    };
    servarr = let
      inherit (my.lib.const.paths.homelab) downloads slowMedia fastMedia;
    in {
      enable = true;
      group = mediaGroup;
      domain = intraDomain;
      dirs = {
        transmission = "${downloads}/torrents";
        sonarr = "${slowMedia}/tv";
        radarr = "${slowMedia}/movies";
        pinchflat = "${slowMedia}/youtube";
        lidarr = "${fastMedia}/music/lidarr";
        spotdl = "${fastMedia}/music/youtube";
      };
      transmission = {
        credentialsFile = config.sops.secrets.transmission_credentials_file.path;
        peerPort = 24334;
        extraSettings = {
          ratio-limit-enabled = true;
          ratio-limit = 2;
          speed-limit-down-enabled = true;
          speed-limit-down = 40000;
          speed-limit-up-enabled = true;
          speed-limit-up = 20000;
        };
      };
      recyclarrEnvironmentFiles = [config.sops.secrets.recyclarr_env_file.path];
      pinchflatEnvironmentFile = config.sops.secrets.pinchflat_env_file.path;
      vpnNamespace = "airvpn";
    };
    kiwix = {
      enable = true;
      libraryPath = "${my.lib.const.paths.homelab.slowMedia}/kiwix";
      reverseProxy.domain = "kiwix.${intraDomain}";
    };
    redlib = {
      enable = true;
      reverseProxy.domain = "redlib.${intraDomain}";
    };
  };

  services.btrbk.sshAccess = [
    {
      key = my.lib.const.sshKeys.btrbkAtSlimbook;
      roles = ["info" "source" "target" "delete"];
    }
  ];
}
