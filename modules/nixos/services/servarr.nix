{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.servarr;
in {
  options.my.services.servarr = let
    serviceName = "servarr";
  in {
    enable = lib.mkEnableOption serviceName;
    group = my.lib.options.mkGroupOption serviceName;

    domain = lib.mkOption {
      type = lib.types.str;
      example = "intra.my.tld";
      description = "The domain for servarr services subdomains.";
    };

    dirs = {
      transmission = my.lib.options.mkDirOption "transmission";
      sonarr = my.lib.options.mkDirOption "sonarr";
      radarr = my.lib.options.mkDirOption "radarr";
      lidarr = my.lib.options.mkDirOption "lidarr";
      spotdl = my.lib.options.mkDirOption "spotdl";
      pinchflat = my.lib.options.mkDirOption "pinchflat";
    };

    transmission = {
      credentialsFile = lib.mkOption {
        type = lib.types.path;
        example = "/path/to/transmission/credentials";
        description = "The path to the transmission credentials file.";
      };

      peerPort = lib.mkOption {
        type = lib.types.int;
        default = 51413;
        example = 24334;
        description = "The port for transmission peer connections.";
      };

      extraSettings = lib.mkOption {
        type = lib.types.attrs;
        default = {};
        example = {
          speed-limit-down-enabled = true;
          speed-limit-down = 20000;
        };
        description = "Extra settings to be added to the Transmission configuration.";
      };
    };

    recyclarrEnvironmentFiles = my.lib.options.mkEnvironmentFilesOption "recyclarr";
    pinchflatEnvironmentFile = my.lib.options.mkEnvironmentFileOption "pinchflat";
    spotdlEnvironmentFile = my.lib.options.mkEnvironmentFileOption "spotdl";

    vpnNamespace = lib.mkOption {
      type = with lib.types; nullOr str;
      default = null;
      example = "proton";
      description = "The name of the VPN namespace. VPN is disabled if not given.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.groups = lib.mkIf (cfg.group == "servarr") {"${cfg.group}" = {};};

    my.services = {
      transmission = {
        enable = true;
        reverseProxy.domain = "transmission.${cfg.domain}";
        downloadsDir = cfg.dirs.transmission;
        inherit (cfg.transmission) credentialsFile peerPort extraSettings;
        inherit (cfg) group vpnNamespace;
      };
      sabnzbd = {
        enable = true;
        reverseProxy.domain = "sabnzbd.${cfg.domain}";
        inherit (cfg) group;
      };
      prowlarr = {
        enable = true;
        reverseProxy.domain = "prowlarr.${cfg.domain}";
        inherit (cfg) vpnNamespace;
      };
      flaresolverr = {
        enable = true;
        reverseProxy.domain = "flaresolverr.${cfg.domain}";
        inherit (cfg) vpnNamespace;
      };
      sonarr = {
        enable = true;
        reverseProxy.domain = "sonarr.${cfg.domain}";
        inherit (cfg) group vpnNamespace;
        mediaDir = cfg.dirs.sonarr;
      };
      radarr = {
        enable = true;
        reverseProxy.domain = "radarr.${cfg.domain}";
        inherit (cfg) group vpnNamespace;
        mediaDir = cfg.dirs.radarr;
      };
      lidarr = {
        enable = true;
        reverseProxy.domain = "lidarr.${cfg.domain}";
        inherit (cfg) group vpnNamespace;
        mediaDir = cfg.dirs.lidarr;
      };
      spotdl = {
        enable = true;
        reverseProxy.domain = "spotdl.${cfg.domain}";
        environmentFile = cfg.spotdlEnvironmentFile;
        inherit (cfg) group;
        mediaDir = cfg.dirs.spotdl;
      };
      pinchflat = {
        enable = true;
        reverseProxy.domain = "pinchflat.${cfg.domain}";
        environmentFile = cfg.pinchflatEnvironmentFile;
        inherit (cfg) group;
        mediaDir = cfg.dirs.pinchflat;
      };
      bazarr = {
        enable = true;
        reverseProxy.domain = "bazarr.${cfg.domain}";
        inherit (cfg) group vpnNamespace;
      };
      jellyfin = {
        enable = true;
        reverseProxy.domain = "jellyfin.${cfg.domain}";
        inherit (cfg) group;
      };
      jellyseerr = {
        enable = true;
        reverseProxy.domain = "jellyseerr.${cfg.domain}";
      };
      recyclarr = {
        enable = true;
        environmentFiles = cfg.recyclarrEnvironmentFiles;
        inherit (cfg) group;
      };
    };
  };
}
