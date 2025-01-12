{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.meilisearch;
in {
  options = {
    my.services.meilisearch = let
      serviceName = "Meilisearch";
    in {
      enable = lib.mkEnableOption serviceName;
      address = my.lib.options.mkAddressOption serviceName;
      port = my.lib.options.mkPortOption serviceName 7700;
      openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
      dataDir = my.lib.options.mkDataDirOption serviceName "/var/lib/meilisearch";

      masterKeyEnvironmentFile = lib.mkOption {
        type = lib.types.path;
        example = "/path/to/env/file";
        description = "The path to the environment file containing a MEILI_MASTER_KEY variable.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];

    services.meilisearch = {
      enable = true;
      listenAddress = cfg.address;
      listenPort = cfg.port;
      noAnalytics = true;
      inherit (cfg) masterKeyEnvironmentFile;
    };

    systemd = {
      services.meilisearch.environment = {
        MEILI_DB_PATH = cfg.dataDir;
        MEILI_DUMP_DIR = "${cfg.dataDir}/dumps";
      };

      tmpfiles.rules = [
        "d '${cfg.dataDir}' 0750 meilisearch meilisearch - -"
      ];
    };
  };
}
