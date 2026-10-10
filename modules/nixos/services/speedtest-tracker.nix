{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.speedtest-tracker;
  caddyCfg = config.services.caddy;

  phpFastcgiConfig = ''
    root * ${config.services.speedtest-tracker.package}/public
    encode zstd gzip
    php_fastcgi unix/${config.services.phpfpm.pools.speedtest-tracker.socket}
    file_server
  '';
in {
  options.my.services.speedtest-tracker = let
    serviceName = "Speedtest Tracker";
  in {
    enable = lib.mkEnableOption serviceName;
    user = my.lib.options.mkUserOption serviceName;
    group = my.lib.options.mkGroupOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 8082;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;

    keyFile = lib.mkOption {
      type = lib.types.path;
      example = "/run/secrets/speedtest-tracker-app-key";
      description = ''
        Path to a file containing the application encryption key. The file
        should contain a 32 character random app key, which may be generated
        with:
          echo "base64:$(head -c 32 /dev/urandom | base64)" > /path/to/key-file
      '';
    };

    servers = lib.mkOption {
      type = with lib.types; listOf int;
      default = [];
      example = [12345 67890];
      description = "List of server IDs to use for speed tests";
    };
    blockedServers = lib.mkOption {
      type = with lib.types; listOf int;
      default = [];
      example = [36998 52365];
      description = "List of blocked server IDs.";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];

    users.groups.${cfg.group}.members = [caddyCfg.user];

    services.speedtest-tracker = {
      enable = true;
      inherit (cfg) user group;
      settings = {
        APP_KEY_FILE = cfg.keyFile;
        APP_URL =
          if cfg.reverseProxy.domain != null
          then "https://${cfg.reverseProxy.domain}"
          else "http://${cfg.address}:${toString cfg.port}";
        DB_CONNECTION = "sqlite";
        DISPLAY_TIMEZONE = "Europe/Warsaw";
        DATETIME_FORMAT = "d.m.y H:i:s";
        CHART_DATETIME_FORMAT = "d.m H:i";
        SPEEDTEST_SCHEDULE = "0 * * * *";
        PUBLIC_DASHBOARD = true;
        SPEEDTEST_SERVERS = lib.concatMapStringsSep "," toString cfg.servers;
        SPEEDTEST_BLOCKED_SERVERS = lib.concatMapStringsSep "," toString cfg.blockedServers;
      };
    };

    services.caddy.virtualHosts =
      {
        "http://${cfg.address}:${toString cfg.port}" = {
          listenAddresses = [cfg.address];
          extraConfig = phpFastcgiConfig;
        };
      }
      // lib.optionalAttrs (cfg.reverseProxy.domain != null) {
        ${cfg.reverseProxy.domain} = {
          inherit (cfg.reverseProxy) listenAddresses;
          logFormat = my.lib.caddy.mkLogConfig cfg.reverseProxy.domain;
          extraConfig = phpFastcgiConfig;
        };
      };
  };
}
