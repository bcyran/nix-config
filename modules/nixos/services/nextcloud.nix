{
  my,
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.my.services.nextcloud;

  caddyCfg = config.services.caddy;
in {
  options.my.services.nextcloud = let
    serviceName = "Nextcloud";
  in {
    enable = lib.mkEnableOption serviceName;
    domain = lib.mkOption {
      type = lib.types.str;
      example = "nextcloud.example.com";
      description = "Domain for the Nextcloud instance.";
    };
    adminPassFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to the file containing the admin password.";
    };
    whiteboardEnvironmentFiles = my.lib.options.mkEnvironmentFilesOption "Nextcloud Whiteboard";

    caddyExtraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Extra Caddy configuration.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.groups.nextcloud.members = ["nextcloud" caddyCfg.user];

    services = {
      nextcloud = {
        enable = true;
        package = pkgs.nextcloud31;
        hostName = cfg.domain;
        https = true;
        maxUploadSize = "16G";

        config = {
          adminuser = "admin";
          adminpassFile = cfg.adminPassFile;
          dbtype = "pgsql";
        };

        database.createLocally = true;
        configureRedis = true;

        extraApps = with config.services.nextcloud.package.packages.apps; {
          inherit
            bookmarks
            calendar
            contacts
            deck
            news
            notes
            tasks
            whiteboard
            richdocuments
            ;
          drawio = pkgs.fetchNextcloudApp {
            sha256 = "sha256-jxm07X+5i7SbxfMDrGOLMkF4mSeGLmYepSAvROdvJwE=";
            url = "https://github.com/jgraph/drawio-nextcloud/releases/download/v3.1.0/drawio-v3.1.0.tar.gz";
            license = "agpl3Only";
          };
          theming_customcss = pkgs.fetchNextcloudApp {
            sha256 = "sha256-MsF+im9yCt7bRNIE8ait0wxcVzMXsHMNbp+IIzY/zJI=";
            url = "https://github.com/nextcloud-releases/theming_customcss/releases/download/v1.18.0/theming_customcss.tar.gz";
            license = "agpl3Only";
          };
          breezedark = pkgs.fetchNextcloudApp {
            sha256 = "sha256-LXoTFFs0Cwqo4yDVAPnqJ9Ovwz9DsrHCGbdesmOypRg=";
            url = "https://github.com/bcyran/nextcloud-breeze-dark/archive/65d3791e96b2beee10828881f325ae3fb45e64d4.tar.gz";
            license = "agpl3Only";
          };
        };
        extraAppsEnable = true;

        settings = {
          default_phone_region = "PL";
          overwriteprotocol = "https";
        };

        phpOptions = {
          "opcache.jit" = "tracing";
          "opcache.jit_buffer_size" = "100M";
          "opcache.interned_strings_buffer" = "16";
        };

        poolSettings = {
          "pm" = "dynamic";
          "pm.max_children" = "200";
          "pm.start_servers" = "50";
          "pm.min_spare_servers" = "25";
          "pm.max_spare_servers" = "50";
          "pm.max_requests" = "500";
          "listen.owner" = lib.mkForce caddyCfg.user;
          "listen.group" = lib.mkForce caddyCfg.group;
        };
      };

      # Caddy module enables nginx by default but we want to use caddy instead.
      nginx.enable = lib.mkForce false;

      # Sources:
      # - https://github.com/onny/nixos-nextcloud-testumgebung/blob/main/nextcloud-extras.nix#L128
      # - https://caddy.community/t/caddy-v2-configuration-nextcloud-docker-php-fpm-with-rules-from-htaccess/20662
      caddy = {
        enable = true;
        virtualHosts.${cfg.domain} = {
          extraConfig = ''
            log {
              ${my.lib.caddy.mkLogConfig cfg.domain}
            }

            ${cfg.caddyExtraConfig}

            # For nextcloud-whiteboard-server
            handle_path /whiteboard/* {
              reverse_proxy http://127.0.0.1:3002
            }

            encode zstd gzip

            root * ${config.services.nginx.virtualHosts.${cfg.domain}.root}

            redir /.well-known/carddav /remote.php/dav 301
            redir /.well-known/caldav /remote.php/dav 301
            redir /.well-known/* /index.php{uri} 301
            redir /remote/* /remote.php{uri} 301

            header {
              Strict-Transport-Security max-age=31536000
              Permissions-Policy interest-cohort=()
              X-Content-Type-Options nosniff
              X-Frame-Options SAMEORIGIN
              Referrer-Policy no-referrer
              X-XSS-Protection "1; mode=block"
              X-Permitted-Cross-Domain-Policies none
              X-Robots-Tag "noindex, nofollow"
              -X-Powered-By
            }

            php_fastcgi unix/${config.services.phpfpm.pools.nextcloud.socket} {
              root ${config.services.nginx.virtualHosts.${cfg.domain}.root}
              env front_controller_active true
              env modHeadersAvailable true
            }

            @forbidden {
              path /build/* /tests/* /config/* /lib/* /3rdparty/* /templates/* /data/*
              path /.* /autotest* /occ* /issue* /indie* /db_* /console*
              not path /.well-known/*
            }
            error @forbidden 404

            @immutable {
              path *.css *.js *.mjs *.svg *.gif *.png *.jpg *.ico *.wasm *.tflite
              query v=*
            }
            header @immutable Cache-Control "max-age=15778463, immutable"

            @static {
              path *.css *.js *.mjs *.svg *.gif *.png *.jpg *.ico *.wasm *.tflite
              not query v=*
            }
            header @static Cache-Control "max-age=15778463"

            @woff2 path *.woff2
            header @woff2 Cache-Control "max-age=604800"

            file_server
          '';
        };
      };

      nextcloud-whiteboard-server = {
        enable = true;
        settings = {
          NEXTCLOUD_URL = "https://${cfg.domain}";
        };
        secrets = cfg.whiteboardEnvironmentFiles;
      };
    };
  };
}
