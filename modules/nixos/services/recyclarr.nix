{
  config,
  lib,
  ...
}: let
  cfg = config.my.services.recyclarr;
in {
  options.my.services.recyclarr = {
    enable = lib.mkEnableOption "recyclarr";
    sonarrApiKeyFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to a file containing the Sonarr API key.";
    };
    radarrApiKeyFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to a file containing the Radarr API key.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.recyclarr = {
      enable = true;
      configuration = {
        sonarr = {
          mysonarr = {
            base_url = "https://${config.my.services.sonarr.reverseProxy.domain}";
            api_key._secret = cfg.sonarrApiKeyFile;
            delete_old_custom_formats = true;
            replace_existing_custom_formats = true;
            include = [
              # Series
              {template = "sonarr-quality-definition-series";}
              # 4k
              {template = "sonarr-v4-quality-profile-web-2160p-alternative";}
              {template = "sonarr-v4-custom-formats-web-2160p";}
              # 1080p
              {template = "sonarr-v4-quality-profile-web-1080p-alternative";}
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
            api_key._secret = cfg.radarrApiKeyFile;
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
    };
  };
}
