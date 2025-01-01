{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.loki;
  grafanaCfg = config.my.services.grafana;

  lokiDataDir = "/var/lib/loki";
in {
  options.my.services.loki = let
    lokiServiceName = "Loki";
    promatilServiceName = "Promtail";
  in {
    enable = lib.mkEnableOption lokiServiceName;
    lokiAddress = my.lib.options.mkAddressOption lokiServiceName;
    lokiPort = my.lib.options.mkPortOption lokiServiceName 3100;
    promtailAddress = my.lib.options.mkAddressOption promatilServiceName;
    promtailPort = my.lib.options.mkPortOption promatilServiceName 3031;
  };

  config.services = lib.mkIf cfg.enable {
    loki = {
      enable = true;
      configuration = {
        server = {
          http_listen_address = cfg.lokiAddress;
          http_listen_port = cfg.lokiPort;
        };
        auth_enabled = false;
        common.path_prefix = lokiDataDir;

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
            active_index_directory = "${lokiDataDir}/tsdb-shipper-active";
            cache_location = "${lokiDataDir}/tsdb-shipper-cache";
            cache_ttl = "24h";
          };

          filesystem = {
            directory = "${lokiDataDir}/chunks";
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
          working_directory = lokiDataDir;
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
          http_listen_address = cfg.promtailAddress;
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

      datasources.settings.datasources = lib.mkIf grafanaCfg.enable [
        {
          name = "Loki";
          type = "loki";
          url = "http://127.0.0.1:${toString cfg.lokiPort}";
        }
      ];
    };
  };
}
