{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.home-assistant;
in {
  options.my.services.home-assistant = let
    serviceName = "Home Assistant";
  in {
    enable = lib.mkEnableOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 8123;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;
  };

  config = lib.mkIf cfg.enable {
    services.home-assistant = {
      enable = true;
      inherit (cfg) openFirewall;

      config = {
        homeassistant = {
          latitude = "!secret home_latitute";
          longitude = "!secret home_longitude";
          country = "PL";
          unit_system = "metric";
          internal_url = "https://${cfg.reverseProxy.domain}";
        };
        http = {
          use_x_forwarded_for = true;
          server_host = cfg.address;
          server_port = cfg.port;
          trusted_proxies = ["127.0.0.1"];
        };
        scene = "!include scenes.yaml";
        automation = "!include automations.yaml";
        script = "!include scripts.yaml";

        mobile_app = {};
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

    my.services.caddy.reverseProxyHosts = my.lib.caddy.mkReverseProxy cfg;
  };
}
