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
      restartUnits = ["podman-speedtest-tracker.service"];
    };
    meilisearch_env_file = {
      restartUnits = ["meilisearch.service"];
    };
    hoarder_env_file = {
      restartUnits = ["podman-hoarder.service"];
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
    nextcloud_whiteboard_env_file = {};
    onlyoffice_env_file = {};
    collabora_env_file = {};
    linkwarden_env_file = {
      restartUnits = ["podman-linkwarden.service"];
    };
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
      peerPort = 24334;
      downloadsDir = "${my.lib.const.paths.homelab.slowStore}/servarr/torrents";
      vpnNamespace = "airvpn";
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
    sonarr = {
      enable = true;
      reverseProxy.domain = "sonarr.${intraDomain}";
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
