{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.iperf;
in {
  options.my.services.iperf = let
    serviceName = "iperf";
  in {
    enable = lib.mkEnableOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 5201;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
  };

  config = lib.mkIf cfg.enable {
    services.iperf3 = {
      enable = true;
      bind = cfg.address;
      inherit (cfg) port openFirewall;
    };
  };
}
