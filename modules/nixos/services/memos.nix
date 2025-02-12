# Memos package is outdated and looks quite hard to fix, see:
# - https://github.com/NixOS/nixpkgs/issues/257131
# - https://github.com/NixOS/nixpkgs/pull/304264
{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.memos;

  memosVersion = "0.23.0";
in {
  options = {
    my.services.memos = let
      serviceName = "Memos";
    in {
      enable = lib.mkEnableOption serviceName;
      address = my.lib.options.mkAddressOption serviceName;
      port = my.lib.options.mkPortOption serviceName 5230;
      openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
      domain = my.lib.options.mkDomainOption serviceName;
      dataDir = my.lib.options.mkDataDirOption serviceName "/var/lib/memos";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];

    virtualisation.oci-containers.containers.memos = {
      image = "neosmemo/memos:${memosVersion}";
      autoStart = true;
      ports = ["${cfg.address}:${builtins.toString cfg.port}:5230"];
      volumes = [
        "${cfg.dataDir}:/var/opt/memos"
      ];
    };

    systemd.tmpfiles.rules = [
      "d '${cfg.dataDir}' 0750 root root - -"
    ];

    my.services.caddy.reverseProxyHosts = lib.optionalAttrs (cfg.domain != null) {
      ${cfg.domain} = {
        upstreamAddress = cfg.address;
        upstreamPort = cfg.port;
      };
    };
  };
}
