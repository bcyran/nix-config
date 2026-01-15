# Onlyoffice in nixpkgs doesn't work with Nextcloud, see:
# - https://github.com/ONLYOFFICE/onlyoffice-nextcloud/issues/931
# - https://github.com/NixOS/nixpkgs/pull/338794
{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.onlyoffice;

  onlyofficeVersion = "9.2";
  dataDir = "/var/lib/onlyoffice";
in {
  options.my.services.onlyoffice = let
    serviceName = "Onlyoffice";
  in {
    enable = lib.mkEnableOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 8086;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;
    environmentFiles = my.lib.options.mkEnvironmentFilesOption serviceName;
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];

    virtualisation.oci-containers.containers.onlyoffice = {
      image = "onlyoffice/documentserver:${onlyofficeVersion}";
      autoStart = true;
      ports = ["${cfg.address}:${builtins.toString cfg.port}:80"];
      volumes = [
        "${dataDir}:/var/lib/onlyoffice"
      ];
      inherit (cfg) environmentFiles;
    };

    systemd.tmpfiles.rules = [
      "d '${dataDir}' 0750 root root - -"
    ];

    my.services.caddy.reverseProxyHosts = my.lib.caddy.mkReverseProxy cfg;
  };
}
