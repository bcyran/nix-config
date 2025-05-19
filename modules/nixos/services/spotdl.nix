{
  pkgs,
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.spotdl;
  spotdlBin = lib.getExe pkgs.spotdl;

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
  ];
  spotdlCommonArgsStr = builtins.concatStringsSep " " spotdlCommonArgs;
  dataDir = "/var/lib/spotdl";
in {
  options.my.services.spotdl = let
    serviceName = "SpotDL";
  in {
    enable = lib.mkEnableOption serviceName;
    user = my.lib.options.mkUserOption serviceName;
    group = my.lib.options.mkGroupOption serviceName;

    mediaDir = lib.mkOption {
      type = lib.types.path;
      example = "/path/to/media";
      description = "The path to the directory for ${serviceName} to store media files.";
    };

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

      services.spotdl-sync = {
        description = "Spotify playlists synchronization service";
        after = ["network.target"];

        serviceConfig = {
          Type = "oneshot";
          User = cfg.user;
          Group = cfg.group;
          WorkingDirectory = cfg.mediaDir;
        };

        script = ''
          set -euo pipefail
          for sync_target in ${cfg.mediaDir}/sync/*.spotdl; do
            echo "Syncing ''${sync_target}..."
            ${spotdlBin} ${spotdlCommonArgsStr} sync ''${sync_target}
          done
        '';

        vpnConfinement = lib.mkIf (cfg.vpnNamespace != null) {
          enable = true;
          inherit (cfg) vpnNamespace;
        };

        startAt = "05:00";
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
  };
}
