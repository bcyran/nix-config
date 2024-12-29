{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.homepage;
in {
  options.my.services.homepage = {
    enable = lib.mkEnableOption "homepage";

    environmentFile = lib.mkOption {
      type = with lib.types; nullOr path;
      default = null;
      description = "The path to the environment file.";
    };

    port = lib.mkOption {
      type = lib.types.int;
      default = 8080;
      description = "The port on which the homepage is accessible.";
    };

    domain = lib.mkOption {
      type = lib.types.str;
      example = "homepage.home.my.tld";
      description = "The domain on which the homepage is accessible.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.homepage-dashboard = {
      enable = true;
      package = my.pkgs.homepage-dashboard;
      inherit (cfg) environmentFile;
      openFirewall = true;
      listenPort = cfg.port;
    };

    my.services.reverseProxy.virtualHosts.${cfg.domain} = {
      backendAddress = "127.0.0.1";
      backendPort = cfg.port;
    };
  };
}
