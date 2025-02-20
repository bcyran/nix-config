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
    dataDir = my.lib.options.mkDataDirOption serviceName "/var/lib/nextcloud";
    domain = lib.mkOption {
      type = lib.types.str;
      example = "nextcloud.example.com";
      description = "Domain for the Nextcloud instance.";
    };
    adminPassFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to the file containing the admin password.";
    };

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
        package = pkgs.nextcloud30;
        hostName = cfg.domain;
        https = true;
        home = cfg.dataDir;
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
            ;
        };
        extraAppsEnable = true;

        settings = {
          default_phone_region = "PL";
          overwriteprotocol = "https";
        };

        phpOptions = {
          "opcache.interned_strings_buffer" = "16";
        };
      };

      # Caddy module enables nginx by default but we want to use caddy instead.
      nginx.enable = lib.mkForce false;

      phpfpm.pools.nextcloud.settings = {
        "listen.owner" = caddyCfg.user;
        "listen.group" = caddyCfg.group;
      };

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
    };
  };
}
