{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.mosquitto;

  userOptions = lib.types.submodule {
    options = {
      acl = lib.mkOption {
        type = with lib.types; listOf str;
        example = [
          "read A/B"
          "readwrite A/#"
        ];
        default = [];
      };
      passwordFile = lib.mkOption {
        type = with lib.types; uniq (nullOr path);
        example = "/path/to/file";
        default = null;
      };
    };
  };
in {
  options.my.services.mosquitto = let
    serviceName = "Mosquitto MQTT broker";
  in {
    enable = lib.mkEnableOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 1883;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;

    users = lib.mkOption {
      type = lib.types.attrsOf userOptions;
      default = {};
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];

    services.mosquitto = {
      enable = true;
      dataDir = "/var/lib/mosquitto";
      listeners = [
        {
          inherit (cfg) address port users;
        }
      ];
    };
  };
}
