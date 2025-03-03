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

    transmissionCredentialsFile = lib.mkOption {
      type = lib.types.path;
      example = "/path/to/transmission/credentials";
      description = "The path to the transmission credentials file.";
    };

    transmissionPeerPort = lib.mkOption {
      type = lib.types.int;
      default = 51413;
      example = 24334;
      description = "The port for transmission peer connections.";
    };

    downloadsDir = lib.mkOption {
      type = lib.types.path;
      example = "/path/to/downloads";
      description = "The path to the temporary storage for downloads / seeding.";
    };

    mediaDir = lib.mkOption {
      type = lib.types.path;
      example = "/path/to/media";
      description = "The path to the media library directory.";
    };

    vpnNamespace = lib.mkOption {
      type = with lib.types; nullOr str;
      default = null;
      example = "proton";
      description = "The name of the VPN namespace. VPN is disabled if not given.";
    };

    enableUnmanic = lib.mkEnableOption "unmanic";
  };

  config = lib.mkIf cfg.enable {
    users.groups = lib.mkIf (cfg.group == "servarr") {"${cfg.group}" = {};};

    my.services = {
      transmission = {
        enable = true;
        reverseProxy.domain = "transmission.${cfg.domain}";
        credentialsFile = cfg.transmissionCredentialsFile;
        peerPort = cfg.transmissionPeerPort;
        downloadsDir = "${cfg.downloadsDir}/torrents";
        inherit (cfg) group vpnNamespace;
      };
      prowlarr = {
        enable = true;
        reverseProxy.domain = "prowlarr.${cfg.domain}";
        inherit (cfg) group vpnNamespace;
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
        mediaDir = "${cfg.mediaDir}/tv";
      };
      radarr = {
        enable = true;
        reverseProxy.domain = "radarr.${cfg.domain}";
        inherit (cfg) group vpnNamespace;
        mediaDir = "${cfg.mediaDir}/movies";
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
      unmanic = {
        enable = cfg.enableUnmanic;
        reverseProxy.domain = "unmanic.${cfg.domain}";
        inherit (cfg) group mediaDir;
      };
    };
  };
}
