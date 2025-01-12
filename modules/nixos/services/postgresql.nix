{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.postgresql;

  effectiveDataDir = "${cfg.dataDir}/${config.services.postgresql.package.psqlSchema}";
in {
  options.my.services.postgresql = let
    serviceName = "PostgreSQL";
  in {
    enable = lib.mkEnableOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 5432;
    dataDir = my.lib.options.mkDataDirOption serviceName "/var/lib/postgresql";
  };

  config = lib.mkIf cfg.enable {
    services.postgresql = {
      enable = true;
      dataDir = effectiveDataDir;

      settings = {
        listen_addresses = lib.mkForce cfg.address;
        inherit (cfg) port;
      };
    };

    systemd.tmpfiles.rules = [
      "d '${effectiveDataDir}' 0750 postgres postgres - -"
    ];
  };
}
