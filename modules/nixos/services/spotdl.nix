{
  pkgs,
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.spotdl;
  spotdlBin = lib.getExe pkgs.spotdl;

  effectiveAddress =
    if cfg.vpnNamespace != null
    then config.vpnNamespaces.${cfg.vpnNamespace}.namespaceAddress
    else "127.0.0.1";
  dataDir = "/var/lib/spotdl";

  spotdlCommonArgs = [
    "--headless"
    "--scan-for-songs"
    "--m3u"
    "'playlists/{list[0]}.m3u8'"
    "--output"
    "'${cfg.mediaDir}/{album-artist}/{album} ({year})/{album-artist} - {album} - {track-number} - {title}.{output-ext}'"
    "--overwrite"
    "skip"
    "--bitrate"
    "disable"
    "--format"
    "m4a"
    "--threads"
    "4"
    "--sync-without-deleting"
    # Default AZlyrics provider had died and a bug causes spotdl to run request retries in an infinite loop.
    # See: https://github.com/spotDL/spotify-downloader/issues/2441.
    "--lyrics"
    "genius musixmatch"
    "--client-id"
    "$SPOTIFY_CLIENT_ID"
    "--client-secret"
    "$SPOTIFY_CLIENT_SECRET"
  ];
  spotdlWebArgs = [
    "--host"
    effectiveAddress
    "--port"
    (builtins.toString cfg.port)
    "--web-use-output-dir"
  ];
  spotdlCommonArgsStr = builtins.concatStringsSep " " spotdlCommonArgs;
  spotdlWebArgsStr = builtins.concatStringsSep " " spotdlWebArgs;
in {
  options.my.services.spotdl = let
    serviceName = "SpotDL";
  in {
    enable = lib.mkEnableOption serviceName;
    user = my.lib.options.mkUserOption serviceName;
    group = my.lib.options.mkGroupOption serviceName;
    port = my.lib.options.mkPortOption serviceName 8089;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;

    mediaDir = lib.mkOption {
      type = lib.types.path;
      example = "/path/to/media";
      description = "The path to the directory for ${serviceName} to store media files.";
    };

    environmentFile = my.lib.options.mkEnvironmentFileOption serviceName;

    vpnNamespace = lib.mkOption {
      type = with lib.types; nullOr str;
      default = null;
      example = "proton";
      description = "The name of the VPN namespace. VPN is disabled if not given.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [pkgs.spotdl];

    systemd = {
      tmpfiles.rules = [
        "d '${dataDir}'       0750 ${cfg.user} ${cfg.group} - -"
        "d '${cfg.mediaDir}'  0775 ${cfg.user} ${cfg.group} - -"
      ];

      services = {
        spotdl = {
          description = "SpotDL web interface";
          after = ["network.target"];
          wantedBy = ["multi-user.target"];

          serviceConfig = {
            Type = "simple";
            User = cfg.user;
            Group = cfg.group;
            WorkingDirectory = cfg.mediaDir;
            ExecStart = "${spotdlBin} web ${spotdlWebArgsStr} ${spotdlCommonArgsStr}";
            EnvironmentFile = cfg.environmentFile;
            Restart = "always";
          };

          vpnConfinement = lib.mkIf (cfg.vpnNamespace != null) {
            enable = true;
            inherit (cfg) vpnNamespace;
          };
        };

        spotdl-sync = {
          description = "Spotify playlists synchronization service";
          after = ["network.target"];

          serviceConfig = {
            Type = "oneshot";
            User = cfg.user;
            Group = cfg.group;
            WorkingDirectory = cfg.mediaDir;
            EnvironmentFile = cfg.environmentFile;
            TimeoutSec = 60 * 60; # 1 hour
          };

          script = ''
            set -euo pipefail
            for sync_target in ${cfg.mediaDir}/sync/*.spotdl; do
              echo "Syncing ''${sync_target}..."
              ${spotdlBin} sync ''${sync_target} ${spotdlCommonArgsStr}
            done

            # Fix paths in generated m3u8 playlists to be relative
            find '${cfg.mediaDir}/playlists' -type f -name '*.m3u8' -exec sed -i 's@${cfg.mediaDir}@..@g' {} \;
          '';

          vpnConfinement = lib.mkIf (cfg.vpnNamespace != null) {
            enable = true;
            inherit (cfg) vpnNamespace;
          };

          startAt = "05:00";
        };
      };
    };

    users = {
      users = lib.mkIf (cfg.user == "spotdl") {
        spotdl = {
          name = "spotdl";
          isSystemUser = true;
          inherit (cfg) group;
          home = dataDir;
        };
      };
      groups = lib.mkIf (cfg.group == "spotdl") {spotdl = {};};
    };

    my.services.caddy.reverseProxyHosts = lib.optionalAttrs (cfg.reverseProxy.domain != null) {
      ${cfg.reverseProxy.domain} = {
        upstreamAddress = effectiveAddress;
        upstreamPort = cfg.port;
      };
    };
  };
}
