{
  my,
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.services.recyclarr;

  recyclarrConfig = {
    sonarr = {
      mysonarr = {
        base_url = "https://${config.my.services.sonarr.reverseProxy.domain}";
        api_key = "!env_var RECYCLARR_SONARR_API_KEY";
        delete_old_custom_formats = true;
        replace_existing_custom_formats = true;
        include = [
          # Series
          {template = "sonarr-quality-definition-series";}
          # 4k
          {template = "sonarr-v4-quality-profile-web-2160p";}
          {template = "sonarr-v4-custom-formats-web-2160p";}
          # 1080p
          {template = "sonarr-v4-quality-profile-web-1080p";}
          {template = "sonarr-v4-custom-formats-web-1080p";}
          # Anime
          {template = "sonarr-quality-definition-anime";}
          {template = "sonarr-v4-quality-profile-anime";}
          {template = "sonarr-v4-custom-formats-anime";}
        ];
        custom_formats = [
          # Allow x265 1080p releases
          {
            trash_ids = ["47435ece6b99a0b477caf360e79ba0bb"]; # x265 (HD)
            assign_scores_to = [
              {
                name = "WEB-1080p";
                score = 0;
              }
            ];
          }
        ];
      };
    };
    radarr = {
      myradarr = {
        base_url = "https://${config.my.services.radarr.reverseProxy.domain}";
        api_key = "!env_var RECYCLARR_RADARR_API_KEY";
        include = [
          # Movies
          {template = "radarr-quality-definition-movie";}
          # 4k
          {template = "radarr-quality-profile-remux-web-2160p";}
          {template = "radarr-custom-formats-remux-web-2160p";}
          {template = "radarr-quality-profile-uhd-bluray-web";}
          {template = "radarr-custom-formats-uhd-bluray-web";}
          # 1080p
          {template = "radarr-quality-profile-remux-web-1080p";}
          {template = "radarr-custom-formats-remux-web-1080p";}
          {template = "radarr-quality-profile-hd-bluray-web";}
          {template = "radarr-custom-formats-hd-bluray-web";}
          # Anime
          {template = "radarr-quality-profile-anime";}
          {template = "radarr-custom-formats-anime";}
        ];
        custom_formats = [
          # Allow x265 1080p releases
          {
            trash_ids = ["dc98083864ea246d05a42df0d05f81cc"]; # x265 (HD)
            assign_scores_to = [
              {
                name = "Remux + WEB 1080p";
                score = 0;
              }
              {
                name = "HD Bluray + WEB";
                score = 0;
              }
            ];
          }
        ];
      };
    };
  };

  yamlFormat = pkgs.formats.yaml {};
  # `pkgs.formats.yaml` does not support yaml tags.
  # See: https://github.com/NixOS/nix/issues/4910#issuecomment-2456085788.
  recyclarrConfigFile = (yamlFormat.generate "recyclarr.yml" recyclarrConfig).overrideAttrs {
    buildCommand = ''
      json2yaml --yaml-width inf "$valuePath" | sed -e "
        s/'\!\([A-Za-z_]\+\) \(.*\)'/\!\1 \2/
        s/^\!\!/\!/
        T
        s/'''/'/g
      " > "$out"
    '';
  };

  dataDir = "/var/lib/recyclarr";
in {
  options.my.services.recyclarr = let
    serviceName = "recyclarr";
  in {
    enable = lib.mkEnableOption serviceName;
    user = my.lib.options.mkUserOption serviceName;
    group = my.lib.options.mkGroupOption serviceName;
    environmentFiles = my.lib.options.mkEnvironmentFilesOption serviceName;
  };

  config = lib.mkIf cfg.enable {
    environment = {
      systemPackages = [pkgs.recyclarr];
      etc."recyclarr/recyclarr.yml".source = recyclarrConfigFile;
    };

    systemd = {
      services.recyclarr = {
        description = "Automatically synchronize servarr recommended settings from TRaSH guides";
        after = ["network.target"];
        startLimitBurst = 5;

        serviceConfig = {
          Type = "oneshot";
          User = cfg.user;
          Group = cfg.group;
          ExecStart = "${lib.getExe pkgs.recyclarr} sync --app-data=${dataDir} --config=/etc/recyclarr/recyclarr.yml";
          Restart = "on-failure";
          EnvironmentFile = cfg.environmentFiles;
        };

        startAt = "daily";
      };
    };

    users = {
      users = lib.mkIf (cfg.user == "recyclarr") {
        recyclarr = {
          name = "recyclarr";
          isSystemUser = true;
          inherit (cfg) group;
        };
      };
      groups = lib.mkIf (cfg.group == "recyclarr") {recyclarr = {};};
    };

    systemd.tmpfiles.rules = [
      "d '${dataDir}' 700 ${cfg.user} ${cfg.group} - -"
    ];
  };
}
