{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.edo-calculator;

  # renovate: datasource=docker packageName=ghcr.io/krbob/edo-calculator
  imageVersion = "sha-eef4742";
  dataDir = "/var/lib/edo-calculator";
  uid = 2003;
in {
  options.my.services.edo-calculator = let
    serviceName = "EDO Calculator";
  in {
    enable = lib.mkEnableOption serviceName;
    user = my.lib.options.mkUserOption serviceName;
    group = my.lib.options.mkGroupOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 8097;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];

      virtualisation.oci-containers.containers.edo-calculator = {
        image = "ghcr.io/krbob/edo-calculator:${imageVersion}";
        autoStart = true;
        ports = ["${cfg.address}:${builtins.toString cfg.port}:8080"];
        podman.user = cfg.user;
        extraOptions = [
          "--cap-drop=ALL"
          "--security-opt=no-new-privileges"
        ];
      };

      my.services.caddy.reverseProxyHosts = my.lib.caddy.mkReverseProxy cfg;
    }

    (my.lib.ociContainers.mkRootlessPodmanUser {
      inherit (cfg) user group;
      home = dataDir;
      inherit uid;
    })
  ]);
}
