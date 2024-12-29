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
      example = "hass.intra.my.tld";
      description = "The domain on which the Home Assistant server listens.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.home-assistant = {
      enable = true;
      openFirewall = true;

      config = {
        homeassistant = {
          latitude = "!secret home_latitute";
          longitude = "!secret home_longitude";
          country = "PL";
          unit_system = "metric";
          internal_url = "https://${cfg.domain}";

          customize = {
            "light.192_168_0_228" = {
              icon = "mdi:light-flood-up";
            };
            "light.192_168_0_227" = {
              icon = "mdi:light-flood-up";
            };
            "light.192_168_0_164" = {
              icon = "mdi:light-flood-up";
            };
            "light.192_168_0_80" = {
              icon = "mdi:desk";
            };
            "light.all_lights" = {
              icon = "mdi:lightbulb-group";
              friendly_name = "Wszystkie światła";
            };
            "light.mood_lights" = {
              icon = "mdi:lightbulb-group";
              friendly_name = "Mood lights";
            };
            "media_player.tv" = {
              icon = "mdi:television";
            };
          };
        };
        http = {
          use_x_forwarded_for = true;
          server_port = cfg.port;
          trusted_proxies = ["127.0.0.1"];
        };
        mobile_app = {};
        yeelight = {
          devices = {
            "192.168.0.228" = {
              name = "Podłoga";
              model = "color4";
            };
            "192.168.0.227" = {
              name = "Łóżko";
              model = "colorb";
            };
            "192.168.0.164" = {
              name = "Stół";
              model = "color4";
            };
            "192.168.0.80" = {
              name = "Biurko";
              model = "strip8";
            };
          };
        };
        light = [
          {
            platform = "group";
            name = "all_lights";
            entities = [
              "light.192_168_0_228"
              "light.192_168_0_227"
              "light.192_168_0_164"
              "light.192_168_0_80"
            ];
          }
          {
            platform = "group";
            name = "mood_lights";
            entities = [
              "light.192_168_0_228"
              "light.192_168_0_227"
              "light.192_168_0_164"
            ];
          }
        ];
      };

      extraComponents = [
        "default_config"
        "met"
        "google_translate"
        "mobile_app"
        "group"
        "ping"
        "device_tracker"
        "media_player"
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
