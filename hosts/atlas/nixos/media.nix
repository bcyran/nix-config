{
  config,
  my,
  ...
}: let
  inherit (my.lib.const.paths.atlas) downloads slowMedia fastMedia;
  intraDomain = my.lib.const.domains.intra;
  mediaGroup = "media";
  vpnNs = "airvpn";
in {
  sops.secrets = {
    airvpn_conf_file = {
      restartUnits = ["airvpn.service"];
    };
    transmission_credentials_file = {
      reloadUnits = ["transmission.service"];
    };
    sonarr_api_key = {
      restartUnits = ["recyclarr.service"];
    };
    radarr_api_key = {
      restartUnits = ["recyclarr.service"];
    };
    jellystat_env_file = {
      restartUnits = ["jellystat.service"];
    };
    pinchflat_env_file = {
      restartUnits = ["pinchflat.service"];
    };
    spotdl_env_file = {
      restartUnits = ["spotdl.service"];
    };
  };

  my.configurations.vpnConfinement = {
    enable = true;
    wireguardConfigFile = config.sops.secrets.airvpn_conf_file.path;
    namespaceName = vpnNs;
  };

  my.services = {
    transmission = {
      enable = true;
      reverseProxy.domain = "transmission.${intraDomain}";
      downloadsDir = "${downloads}/torrents";
      credentialsFile = config.sops.secrets.transmission_credentials_file.path;
      peerPort = 24334;
      group = mediaGroup;
      vpnNamespace = vpnNs;
      extraSettings = {
        speed-limit-down-enabled = true;
        speed-limit-down = 40000;
        speed-limit-up-enabled = true;
        speed-limit-up = 20000;
      };
    };
    sabnzbd = {
      enable = true;
      reverseProxy.domain = "sabnzbd.${intraDomain}";
      group = mediaGroup;
      extraSettings = {
        misc = {
          bandwidth_max = "110MB/s";
          bandwidth_perc = 70;
          cache_limit = "4G";
        };
      };
    };
    prowlarr = {
      enable = true;
      reverseProxy.domain = "prowlarr.${intraDomain}";
      vpnNamespace = vpnNs;
    };
    flaresolverr = {
      enable = true;
      reverseProxy.domain = "flaresolverr.${intraDomain}";
      vpnNamespace = vpnNs;
    };
    sonarr = {
      enable = true;
      reverseProxy.domain = "sonarr.${intraDomain}";
      group = mediaGroup;
      vpnNamespace = vpnNs;
      mediaDir = "${slowMedia}/tv";
    };
    radarr = {
      enable = true;
      reverseProxy.domain = "radarr.${intraDomain}";
      group = mediaGroup;
      vpnNamespace = vpnNs;
      mediaDir = "${slowMedia}/movies";
    };
    lidarr = {
      enable = true;
      reverseProxy.domain = "lidarr.${intraDomain}";
      group = mediaGroup;
      vpnNamespace = vpnNs;
      mediaDir = "${fastMedia}/music/lidarr";
    };
    spotdl = {
      enable = true;
      reverseProxy.domain = "spotdl.${intraDomain}";
      environmentFile = config.sops.secrets.spotdl_env_file.path;
      group = mediaGroup;
      mediaDir = "${fastMedia}/music/youtube";
    };
    pinchflat = {
      enable = true;
      reverseProxy.domain = "pinchflat.${intraDomain}";
      environmentFile = config.sops.secrets.pinchflat_env_file.path;
      group = mediaGroup;
      mediaDir = "${slowMedia}/youtube";
    };
    bazarr = {
      enable = true;
      reverseProxy.domain = "bazarr.${intraDomain}";
      group = mediaGroup;
      vpnNamespace = vpnNs;
    };
    jellyfin = {
      enable = true;
      reverseProxy.domain = "jellyfin.${intraDomain}";
      group = mediaGroup;
    };
    jellyseerr = {
      enable = true;
      reverseProxy.domain = "jellyseerr.${intraDomain}";
    };
    recyclarr = {
      enable = true;
      sonarrApiKeyFile = config.sops.secrets.sonarr_api_key.path;
      radarrApiKeyFile = config.sops.secrets.radarr_api_key.path;
    };
    cleanuparr = {
      enable = true;
      reverseProxy.domain = "cleanuparr.${intraDomain}";
    };
    jellystat = {
      enable = true;
      environmentFiles = [config.sops.secrets.jellystat_env_file.path];
      reverseProxy.domain = "jellystat.${intraDomain}";
    };
    calibre-web = {
      enable = true;
      group = mediaGroup;
      reverseProxy.domain = "calibre.${intraDomain}";
      calibreLibrary = "${fastMedia}/ebooks/calibre";
    };
    audiobookshelf = {
      enable = true;
      group = mediaGroup;
      reverseProxy.domain = "audiobookshelf.${intraDomain}";
    };
    kiwix = {
      enable = true;
      libraryPath = "${slowMedia}/kiwix";
      reverseProxy.domain = "kiwix.${intraDomain}";
    };
  };
}
