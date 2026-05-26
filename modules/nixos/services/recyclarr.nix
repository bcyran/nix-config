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
            quality_definition.type = "series";
            quality_profiles = [
              # 4k
              {
                trash_id = "dfa5eaae7894077ad6449169b6eb03e0"; # WEB-2160p (Alternative)
                name = "WEB-2160p";
              }
              # 1080p
              {
                trash_id = "9d142234e45d6143785ac55f5a9e8dc9"; # WEB-1080p (Alternative)
                name = "WEB-1080p";
              }
              # Anime
              {
                trash_id = "20e0fc959f1f1704bed501f23bdae76f"; # [Anime] Remux-1080p
                name = "Remux-1080p - Anime";
              }
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
            quality_definition.type = "movie";
            quality_profiles = [
              # 4k
              {
                trash_id = "fd161a61e3ab826d3a22d53f935696dd"; # Remux + WEB 2160p
                name = "Remux + WEB 2160p";
              }
              {
                trash_id = "64fb5f9858489bdac2af690e27c8f42f"; # UHD Bluray + WEB
                name = "UHD Bluray + WEB";
              }
              # 1080p
              {
                trash_id = "9ca12ea80aa55ef916e3751f4b874151"; # Remux + WEB 1080p
                name = "Remux + WEB 1080p";
              }
              {
                trash_id = "d1d67249d3890e49bc12e275d989a7e9"; # HD Bluray + WEB
                name = "HD Bluray + WEB";
              }
              # Anime
              {
                trash_id = "722b624f9af1e492284c4bc842153a38"; # [Anime] Remux-1080p
                name = "Remux-1080p - Anime";
              }
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
