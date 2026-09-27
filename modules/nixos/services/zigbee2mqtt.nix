{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.zigbee2mqtt;
in {
  options.my.services.zigbee2mqtt = let
    serviceName = "Zigbee2MQTT";
  in {
    enable = lib.mkEnableOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 8105;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;

    serialPort = lib.mkOption {
      type = lib.types.str;
      example = "/dev/serial/by-id/usb-ITead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_xxxxxxxx-if00-port0";
      description = ''
        Device path of the Zigbee coordinator adapter.
        Use a stable `/dev/serial/by-id/...` path rather than `/dev/tty...`.
      '';
    };

    mqtt = {
      server = lib.mkOption {
        type = lib.types.str;
        default = "mqtt://localhost:1883";
        description = "MQTT server URL to connect to.";
      };

      user = lib.mkOption {
        type = lib.types.str;
        default = "zigbee2mqtt";
        description = "MQTT username to authenticate with.";
      };
    };

    secretFile = lib.mkOption {
      type = lib.types.path;
      example = "/run/secrets/zigbee2mqtt-secret.yaml";
      description = ''
        Path to a YAML file with secrets (mqtt_password and auth_token).
        The file name must end with `.yaml` or `.yml`.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.zigbee2mqtt = {
      enable = true;

      settings = {
        homeassistant.enabled = true;
        permit_join = false;

        serial = {
          port = cfg.serialPort;
          adapter = "ember";
        };

        mqtt = {
          server = cfg.mqtt.server;
          user = cfg.mqtt.user;
          password = "!${cfg.secretFile} mqtt_password";
        };

        frontend = {
          enabled = true;
          host = cfg.address;
          inherit (cfg) port;
          auth_token = "!${cfg.secretFile} auth_token";
        };
      };
    };

    my.services.caddy.reverseProxyHosts = my.lib.caddy.mkReverseProxy cfg;
  };
}
