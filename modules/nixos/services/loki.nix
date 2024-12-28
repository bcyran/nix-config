{
  config,
  lib,
  ...
}: let
  cfg = config.my.services.loki;
in {
  options.my.services.loki = {
    enable = lib.mkEnableOption "loki";

    lokiPort = lib.mkOption {
      type = lib.types.int;
      default = 3100;
      description = "The port on which the Loki server listens.";
    };
    promtailPort = lib.mkOption {
      type = lib.types.int;
      default = 3031;
      description = "The port on which the Promtail server listens.";
    };
  };

  config.services = lib.mkIf cfg.enable {
    loki = {
      enable = true;
      configuration = {
        server.http_listen_port = cfg.lokiPort;
        auth_enabled = false;
        common.path_prefix = "/var/lib/loki";

        ingester = {
          lifecycler = {
            address = "127.0.0.1";
            ring = {
              kvstore = {
                store = "inmemory";
              };
              replication_factor = 1;
            };
          };
          chunk_idle_period = "1h";
          max_chunk_age = "1h";
          chunk_target_size = 999999;
          chunk_retain_period = "30s";
        };

        schema_config = {
          configs = [
            {
              from = "2024-12-01";
              store = "tsdb";
              object_store = "filesystem";
              schema = "v13";
              index = {
                prefix = "index_";
                period = "24h";
              };
            }
          ];
        };

        storage_config = {
          tsdb_shipper = {
            active_index_directory = "/var/lib/loki/tsdb-shipper-active";
            cache_location = "/var/lib/loki/tsdb-shipper-cache";
            cache_ttl = "24h";
          };

          filesystem = {
            directory = "/var/lib/loki/chunks";
          };
        };

        limits_config = {
          reject_old_samples = true;
          reject_old_samples_max_age = "168h";
        };

        table_manager = {
          retention_deletes_enabled = false;
          retention_period = "0s";
        };

        compactor = {
          working_directory = "/var/lib/loki";
          delete_request_store = "filesystem";
          compactor_ring = {
            kvstore = {
              store = "inmemory";
            };
          };
        };
      };
    };

    promtail = {
      enable = true;

      configuration = {
        server = {
          http_listen_port = cfg.promtailPort;
          grpc_listen_port = 0;
        };

        positions = {
          filename = "/tmp/positions.yaml";
        };

        clients = [
          {
            url = "http://127.0.0.1:${toString cfg.lokiPort}/loki/api/v1/push";
          }
        ];

        scrape_configs = [
          {
            job_name = "journal";
            journal = {
              max_age = "12h";
              labels = {
                job = "systemd-journal";
                host = config.networking.hostName;
              };
            };
            relabel_configs = [
              {
                source_labels = ["__journal__systemd_unit"];
                target_label = "unit";
              }
            ];
          }
        ];
      };
    };

    grafana.provision = {
      enable = true;

      datasources.settings.datasources = lib.mkIf config.services.grafana.enable [
        {
          name = "Loki";
          type = "loki";
          url = "http://127.0.0.1:${toString config.my.services.loki.lokiPort}";
        }
      ];
    };
  };
}
