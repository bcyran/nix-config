{
  config,
  lib,
  ...
}: let
  cfg = config.my.services.home-assistant;
in {
  options.my.services.home-assistant = {
    enable = lib.mkEnableOption "home-assistant";

    port = lib.mkOption {
      type = lib.types.int;
      default = 8123;
      description = "The port on which the Home Assistant server listens.";
    };

    domain = lib.mkOption {
      type = lib.types.str;
      example = "ha.intra.my.tld";
      description = "The domain on which the Home Assistant server listens.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.home-assistant = {
      enable = true;
      openFirewall = true;

      config = {
        homeassistant = {
          latitude = 51.1;
          longitude = 17.0;
          country = "PL";
          unit_system = "metric";
          internal_url = "https://${cfg.domain}";
        };
        http = {
          use_x_forwarded_for = true;
          server_port = cfg.port;
          trusted_proxies = ["127.0.0.1"];
        };
        mobile_app = {};
      };

      extraComponents = [
        "default_config"
        "met"
        "google_translate"
        "mobile_app"
        "yeelight"
        "philips_js"
      ];
    };

    my.services.reverseProxy.virtualHosts.${cfg.domain} = {
      backendAddress = "127.0.0.1";
      backendPort = cfg.port;
    };
  };
}
