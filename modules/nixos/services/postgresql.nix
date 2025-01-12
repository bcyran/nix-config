{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.postgresql;
in {
  options.my.services.postgresql = let
    serviceName = "PostgreSQL";
  in {
    enable = lib.mkEnableOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 5432;
  };

  config = lib.mkIf cfg.enable {
    services.postgresql = {
      enable = true;
      settings = {
        listen_addresses = lib.mkForce cfg.address;
        inherit (cfg) port;
      };
    };
  };
}
