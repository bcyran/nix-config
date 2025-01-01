{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.homepage;
in {
  options.my.services.homepage = let
    serviceName = "Homepage dashboard";
  in {
    # I couldn't find a way to configure the bind address so there's no option for it.
    enable = lib.mkEnableOption serviceName;
    port = my.lib.options.mkPortOption serviceName 8080;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    domain = my.lib.options.mkDomainOption serviceName;
    environmentFile = my.lib.options.mkEnvironmentFileOption serviceName;
  };

  config = lib.mkIf cfg.enable {
    services.homepage-dashboard = {
      enable = true;
      package = my.pkgs.homepage-dashboard;
      inherit (cfg) openFirewall environmentFile;
      listenPort = cfg.port;
    };

    my.reverseProxy.virtualHosts.${cfg.domain} = {
      backendAddress = "127.0.0.1";
      backendPort = cfg.port;
    };
  };
}
