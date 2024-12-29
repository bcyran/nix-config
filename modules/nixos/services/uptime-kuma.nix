{
  config,
  lib,
  ...
}: let
  cfg = config.my.services.uptime-kuma;
in {
  options.my.services.uptime-kuma = {
    enable = lib.mkEnableOption "uptime-kuma";

    port = lib.mkOption {
      type = lib.types.int;
      default = 8081;
      description = "The port on which the Uptime Kuma is accessible.";
    };

    domain = lib.mkOption {
      type = lib.types.str;
      example = "uptime-kuma.home.my.tld";
      description = "The domain on which the web UI is accessible.";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [cfg.port];

    services.uptime-kuma = {
      enable = true;
      settings = {
        UPTIME_KUMA_PORT = builtins.toString cfg.port;
      };
    };

    my.services.reverseProxy.virtualHosts.${cfg.domain} = {
      backendAddress = "127.0.0.1";
      backendPort = cfg.port;
    };
  };
}
