{
  config,
  my,
  lib,
  ...
}: let
  intraDomain = my.lib.const.domains.intra;

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
    syncthing = {
      enable = true;
      openFirewallTransfer = true;
      reverseProxy.domain = "syncthing.${intraDomain}";
      keyFile = config.sops.secrets.syncthing_key_file.path;
      certFile = config.sops.secrets.syncthing_cert_file.path;
      environmentFiles = [config.sops.secrets.syncthing_env_file.path];
      inherit (my.lib.const.syncthing) devices;
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
      blockedServers = [5679]; # My ISP's server, shows higher speeds than actual.
    };
    glances = {
      enable = true;
      reverseProxy.domain = "glances.${intraDomain}";
    };
    postgresql.enable = true;
    linkwarden = {
      enable = true;
      environmentFiles = [config.sops.secrets.linkwarden_env_file.path];
      reverseProxy.domain = "linkwarden.${intraDomain}";
      llm = "phi3";
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
    samba = {
      enable = true;
      openFirewall = true;
      validUsers = [config.my.user.name];
      shares = let
        inherit (my.lib.const.paths.homelab) fastStore slowStore;
      in {
        "fast_store" = "${fastStore}/share";
        "slow_store" = "${slowStore}/share";
      };
    };
    servarr = let
      inherit (my.lib.const.paths.homelab) downloads slowMedia;
    in {
      enable = true;
      domain = intraDomain;
      dirs = {
        transmission = "${downloads}/torrents";
        sonarr = "${slowMedia}/tv";
        radarr = "${slowMedia}/movies";
        lidarr = "${slowMedia}/music/lidarr";
        spotdl = "${slowMedia}/music/youtube";
        pinchflat = "${slowMedia}/youtube";
      };
      transmissionCredentialsFile = config.sops.secrets.transmission_credentials_file.path;
      transmissionPeerPort = 24334;
      transmissionExtraSettings = {
        ratio-limit-enabled = true;
        ratio-limit = 2;
        speed-limit-down-enabled = true;
        speed-limit-down = 40000;
        speed-limit-up-enabled = true;
        speed-limit-up = 20000;
      };
      recyclarrEnvironmentFiles = [config.sops.secrets.recyclarr_env_file.path];
      pinchflatEnvironmentFile = config.sops.secrets.pinchflat_env_file.path;
      vpnNamespace = "airvpn";
    };
  };

  services.btrbk.sshAccess = [
    {
      key = my.lib.const.sshKeys.btrbkAtSlimbook;
      roles = ["info" "source" "target" "delete"];
    }
  ];
}
