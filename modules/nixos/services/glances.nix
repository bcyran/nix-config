{
  config,
  lib,
  ...
}: let
  cfg = config.my.services.glances;
in {
  options = {
    my.services.glances = {
      enable = lib.mkEnableOption "glances";

      port = lib.mkOption {
        type = lib.types.int;
        default = 61208;
        description = "The port on which the Glances web UI is accessible.";
      };

      domain = lib.mkOption {
        type = lib.types.str;
        example = "glances.home.my.tld";
        description = "The domain on which the web UI is accessible.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.glances = {
      enable = true;
      inherit (cfg) port;
      openFirewall = true;
      extraArgs = ["--webserver"];
    };

    my.services.reverseProxy.virtualHosts.${cfg.domain} = {
      backendAddress = "127.0.0.1";
      backendPort = cfg.port;
    };
  };
}
