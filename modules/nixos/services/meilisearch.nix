{
  config,
  lib,
  ...
}: let
  cfg = config.my.services.meilisearch;
in {
  options = {
    my.services.meilisearch = {
      enable = lib.mkEnableOption "meilisearch";

      port = lib.mkOption {
        type = lib.types.int;
        default = 7700;
        description = "The port on which the Meilisearch server listens.";
      };

      masterKeyEnvironmentFile = lib.mkOption {
        type = lib.types.path;
        example = "/path/to/env/file";
        description = "The path to the environment file containing a MEILI_MASTER_KEY variable.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [cfg.port];

    services.meilisearch = {
      enable = true;
      listenAddress = "0.0.0.0";
      listenPort = cfg.port;
      noAnalytics = true;
      inherit (cfg) masterKeyEnvironmentFile;
    };
  };
}
