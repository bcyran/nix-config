{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.navidrome;
in {
  options.my.services.navidrome = let
    serviceName = "Navidrome";
  in {
    enable = lib.mkEnableOption serviceName;
    user = my.lib.options.mkUserOption serviceName;
    group = my.lib.options.mkGroupOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 4533;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;

    mediaDir = lib.mkOption {
      type = lib.types.path;
      example = "/path/to/media";
      description = "The path to the directory where ${serviceName} should store media files.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.navidrome = {
      enable = true;
      inherit (cfg) user group openFirewall;
      settings = {
        Address = cfg.address;
        Port = cfg.port;
        MusicFolder = cfg.mediaDir;
      };
    };

    my.services.caddy.reverseProxyHosts = my.lib.caddy.mkReverseProxy cfg;
  };
}
