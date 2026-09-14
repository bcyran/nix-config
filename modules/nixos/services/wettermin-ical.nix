{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.wettermin-ical;
in {
  options.my.services.wettermin-ical = let
    serviceName = "wettermin-ical";
  in {
    enable = lib.mkEnableOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 8090;
    reverseProxy = my.lib.options.mkReverseProxyOptions serviceName;
  };

  config = lib.mkIf cfg.enable {
    sops.secrets.wettermin_keys_file.restartUnits = ["wettermin-ical.service"];

    services.wettermin-ical = {
      enable = true;
      host = cfg.address;
      inherit (cfg) port;
      apiKeyFile = config.sops.secrets.wettermin_keys_file.path;
    };

    my.services.caddy.reverseProxyHosts = my.lib.caddy.mkReverseProxy cfg;
  };
}
