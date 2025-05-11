{config, ...}: let
  servicesCfg = config.my.services;
  makeServiceDomainUrl = serviceName: "https://${servicesCfg.${serviceName}.reverseProxy.domain}";
  makeLoopbackUrl = port: "http://127.0.0.1:${toString port}";
  makeServiceLoopbackUrl = serviceName: makeLoopbackUrl servicesCfg.${serviceName}.port;
in {
  services.homepage-dashboard = {
    settings = {
      hideVersion = true;
      statusStyle = "dot";
      theme = "dark";

      layout = [
        {
          "Hardware status" = {
            style = "row";
            columns = 3;
          };
        }
        {
          Applications = {
            style = "row";
            columns = 3;
          };
        }
        {
          Media = {
            style = "row";
            columns = 3;
          };
        }
        {
          Monitoring = {
            style = "row";
            columns = 3;
          };
        }
        {
          Backend = {
            style = "row";
            columns = 3;
          };
        }
      ];
    };

    services = [
      {
        "Hardware status" = let
          makeGlancesWidget = title: metricName: {
            "${title}" = {
              widget = {
                type = "glances";
                url = makeServiceLoopbackUrl "glances";
                version = "4";
                metric = metricName;
                refreshInterval = 3000;
                chart = false;
              };
            };
          };
        in [
          (makeGlancesWidget "CPU" "cpu")
          (makeGlancesWidget "Memory" "memory")
          (makeGlancesWidget "Network" "network:enp0s31f6")
          (makeGlancesWidget "Root FS" "fs:/")
          (makeGlancesWidget "Fast Store FS" "fs:/mnt/fast_store")
          (makeGlancesWidget "Slow Store FS" "fs:/mnt/slow_store")
        ];
      }
      {
        "Applications" = [
          {
            Nextcloud = rec {
              description = "Personal cloud storage and productivity suite.";
              icon = "nextcloud";
              href = "https://${config.my.services.nextcloud.domain}";
              siteMonitor = href;
              widget = {
                type = "nextcloud";
                url = siteMonitor;
                key = "{{HOMEPAGE_VAR_NEXTCLOUD_SERVERINFO_TOKEN}}";
                fields = ["freespace" "numfiles"];
              };
            };
          }
          {
            Immich = rec {
              description = "Photos and videos management.";
              icon = "immich";
              href = makeServiceDomainUrl "immich";
              siteMonitor = makeServiceLoopbackUrl "immich";
              widget = {
                type = "immich";
                url = siteMonitor;
                key = "{{HOMEPAGE_VAR_IMMICH_API_KEY}}";
                version = 2;
                fields = ["photos" "videos" "storage"];
              };
            };
          }
          {
            Linkwarden = rec {
              description = "Bookmark manager.";
              icon = "linkwarden";
              href = makeServiceDomainUrl "linkwarden";
              siteMonitor = makeServiceLoopbackUrl "linkwarden";
              widget = {
                type = "linkwarden";
                url = siteMonitor;
                key = "{{HOMEPAGE_VAR_LINKWARDEN_API_KEY}}";
                fields = ["links" "collections" "tags"];
              };
            };
          }
          {
            "Home Assistant" = rec {
              description = "Home automation service.";
              icon = "home-assistant";
              href = makeServiceDomainUrl "home-assistant";
              siteMonitor = makeServiceLoopbackUrl "home-assistant";
              widget = {
                type = "homeassistant";
                url = siteMonitor;
                key = "{{HOMEPAGE_VAR_HASS_API_TOKEN}}";
                fields = ["people_home" "lights_on"];
              };
            };
          }
          {
            Forgejo = rec {
              description = "Git server.";
              icon = "forgejo";
              href = makeServiceDomainUrl "forgejo";
              siteMonitor = makeServiceLoopbackUrl "forgejo";
              widget = {
                type = "customapi";
                url = "${siteMonitor}/api/v1/repos/search?limit=100";
                headers = {
                  "Authorization" = "token {{HOMEPAGE_VAR_FORGEJO_API_TOKEN}}";
                };
                refreshInterval = 30000;
                mappings = [
                  {
                    field = "data";
                    format = "size";
                    label = "Repositories";
                  }
                ];
              };
            };
          }
          {
            Syncthing = rec {
              description = "File synchronization service.";
              icon = "syncthing";
              href = makeServiceDomainUrl "syncthing";
              siteMonitor = makeLoopbackUrl servicesCfg.syncthing.guiPort;
              widget = {
                type = "customapi";
                url = "${siteMonitor}/rest/db/completion";
                headers = {
                  "X-API-Key" = "{{HOMEPAGE_VAR_SYNCTHING_API_KEY}}";
                };
                mappings = [
                  {
                    field = "completion";
                    label = "Sync progress";
                    format = "percent";
                  }
                  {
                    field = "needBytes";
                    label = "Unsynced data";
                    format = "bytes";
                  }
                  {
                    field = "globalBytes";
                    label = "Total data";
                    format = "bytes";
                  }
                ];
              };
            };
          }
          {
            "Uptime Kuma" = rec {
              description = "Service uptime monitoring.";
              icon = "uptime-kuma";
              href = "${makeServiceDomainUrl "uptime-kuma"}/status/external";
              siteMonitor = makeServiceLoopbackUrl "uptime-kuma";
              widget = {
                type = "uptimekuma";
                url = siteMonitor;
                slug = "external";
              };
            };
          }
          {
            "Speedtest Tracker" = rec {
              description = "Continuous internet speed monitoring.";
              icon = "myspeed";
              href = makeServiceDomainUrl "speedtest-tracker";
              siteMonitor = makeServiceLoopbackUrl "speedtest-tracker";
              widget = {
                type = "speedtest";
                url = siteMonitor;
              };
            };
          }
          {
            Ollama = rec {
              description = "LLM API service.";
              icon = "ollama";
              siteMonitor = makeServiceLoopbackUrl "ollama";
              widget = {
                type = "customapi";
                url = "${siteMonitor}/api/ps";
                mappings = [
                  {
                    field = "models";
                    label = "Running models";
                    format = "size";
                  }
                ];
              };
            };
          }
          {
            Joplin = {
              description = "Notes synchronization.";
              icon = "joplin";
              href = makeServiceDomainUrl "joplin";
              siteMonitor = makeServiceLoopbackUrl "joplin";
            };
          }
          {
            "ntfy.sh" = {
              description = "Push notifications service.";
              icon = "ntfy";
              href = makeServiceDomainUrl "ntfy";
              siteMonitor = makeServiceLoopbackUrl "ntfy";
            };
          }
          {
            "nix-serve" = {
              description = "Nix binary cache server.";
              icon = "https://nix.dev/_static/img/nix.svg";
              siteMonitor = "${makeServiceLoopbackUrl "nix-serve"}/nix-cache-info";
            };
          }
          {
            "Open WebUI" = {
              description = "OpenAI API service.";
              icon = "https://docs.openwebui.com/images/logo-dark.png";
              href = makeServiceDomainUrl "open-webui";
              siteMonitor = makeServiceLoopbackUrl "open-webui";
            };
          }
        ];
      }
      {
        "Media" = [
          {
            Jellyfin = rec {
              description = "Media server.";
              icon = "jellyfin";
              href = makeServiceDomainUrl "jellyfin";
              siteMonitor = makeServiceDomainUrl "jellyfin";
              widget = {
                type = "jellyfin";
                url = siteMonitor;
                key = "{{HOMEPAGE_VAR_JELLYFIN_API_KEY}}";
                enableBlocks = false;
                enableNowPlaying = true;
                enableUser = true;
                showEpisodeNumber = true;
                expandOneStreamToTwoRows = false;
              };
            };
          }
          {
            Jellyseerr = rec {
              description = "Media requests manager.";
              icon = "jellyseerr";
              href = makeServiceDomainUrl "jellyseerr";
              siteMonitor = makeServiceDomainUrl "jellyseerr";
              widget = {
                type = "jellyseerr";
                url = siteMonitor;
                key = "{{HOMEPAGE_VAR_JELLYSEERR_API_KEY}}";
                fields = ["pending" "approved" "available"];
              };
            };
          }
          {
            Transmission = rec {
              description = "BitTorrent client.";
              icon = "transmission";
              href = makeServiceDomainUrl "transmission";
              siteMonitor = makeServiceDomainUrl "transmission";
              widget = {
                type = "transmission";
                url = siteMonitor;
                username = "{{HOMEPAGE_VAR_TRANSMISSION_USERNAME}}";
                password = "{{HOMEPAGE_VAR_TRANSMISSION_PASSWORD}}";
              };
            };
          }
          {
            Sonarr = rec {
              description = "TV shows manager.";
              icon = "sonarr";
              href = makeServiceDomainUrl "sonarr";
              siteMonitor = makeServiceDomainUrl "sonarr";
              widget = {
                type = "sonarr";
                url = siteMonitor;
                key = "{{HOMEPAGE_VAR_SONARR_API_KEY}}";
              };
            };
          }
          {
            Radarr = rec {
              description = "Movies manager.";
              icon = "radarr";
              href = makeServiceDomainUrl "radarr";
              siteMonitor = makeServiceDomainUrl "radarr";
              widget = {
                type = "radarr";
                url = siteMonitor;
                key = "{{HOMEPAGE_VAR_RADARR_API_KEY}}";
              };
            };
          }
          {
            Prowlarr = rec {
              description = "Indexer manager.";
              icon = "prowlarr";
              href = makeServiceDomainUrl "prowlarr";
              siteMonitor = makeServiceDomainUrl "prowlarr";
              widget = {
                type = "prowlarr";
                url = siteMonitor;
                key = "{{HOMEPAGE_VAR_PROWLARR_API_KEY}}";
              };
            };
          }
          {
            Bazarr = rec {
              description = "Subtitles manager.";
              icon = "bazarr";
              href = makeServiceDomainUrl "bazarr";
              siteMonitor = makeServiceDomainUrl "bazarr";
              widget = {
                type = "bazarr";
                url = siteMonitor;
                key = "{{HOMEPAGE_VAR_BAZARR_API_KEY}}";
              };
            };
          }
          {
            Pinchflat = {
              description = "Automated YouTube downloader.";
              icon = "pinchflat";
              href = makeServiceDomainUrl "pinchflat";
              siteMonitor = makeServiceDomainUrl "pinchflat";
            };
          }
        ];
      }
      {
        "Monitoring" = [
          {
            Grafana = rec {
              description = "Server metrics visualization.";
              icon = "https://upload.wikimedia.org/wikipedia/commons/archive/a/a1/20230113183100%21Grafana_logo.svg";
              href = makeServiceDomainUrl "grafana";
              siteMonitor = makeServiceLoopbackUrl "grafana";
              widget = {
                type = "grafana";
                url = siteMonitor;
                username = "{{HOMEPAGE_VAR_GRAFANA_USERNAME}}";
                fields = ["alertstriggered" "datasources"];
                password = "{{HOMEPAGE_VAR_GRAFANA_PASSWORD}}";
              };
            };
          }
          {
            Prometheus = rec {
              description = "Server metrics collection.";
              icon = "prometheus";
              href = makeServiceDomainUrl "prometheus";
              siteMonitor = makeServiceLoopbackUrl "prometheus";
              widget = {
                type = "prometheus";
                url = siteMonitor;
                fields = ["targets_up" "targets_down"];
              };
            };
          }
          {
            Glances = {
              description = "Live resources usage monitoring.";
              icon = "glances";
              href = makeServiceDomainUrl "glances";
              siteMonitor = makeServiceLoopbackUrl "glances";
            };
          }
          {
            Loki = {
              description = "Log aggregation service.";
              icon = "https://grafana.com/static/img/logos/logo-loki.svg";
              siteMonitor = "${makeLoopbackUrl servicesCfg.loki.lokiPort}/ready";
            };
          }
          {
            Promtail = {
              description = "Log collector.";
              icon = "https://grafana.com/static/img/logos/logo-loki.svg";
              siteMonitor = "${makeLoopbackUrl servicesCfg.loki.promtailPort}/ready";
            };
          }
        ];
      }
      {
        "Backend" = [
          {
            Caddy = {
              description = "Reverse proxy and TLS termination.";
              icon = "caddy";
              siteMonitor = "${makeLoopbackUrl servicesCfg.caddy.adminPort}/reverse_proxy/upstreams";
              widget = {
                type = "caddy";
                url = "${makeLoopbackUrl servicesCfg.caddy.adminPort}";
              };
            };
          }
          {
            Blocky = {
              description = "DNS server with ad blocking.";
              icon = "blocky";
              siteMonitor = makeLoopbackUrl servicesCfg.blocky.httpPort;
              widget = {
                type = "prometheusmetric";
                url = makeServiceLoopbackUrl "prometheus";
                metrics = let
                  range = "1h";
                in [
                  {
                    label = "Queries count [${range}]";
                    query = "ceil(sum(increase(blocky_query_total[${range}])))";
                    format = {
                      type = "number";
                      options.maximumFractionDigits = 0;
                    };
                  }
                  {
                    label = "Queries blocked [${range}]";
                    query = "sum(increase(blocky_response_total{response_type='BLOCKED'}[${range}])) / sum(increase(blocky_query_total[${range}]))";
                    format = {
                      type = "number";
                      scale = 100;
                      options.maximumFractionDigits = 2;
                      suffix = "%";
                    };
                  }
                  {
                    label = "Avg. response time [${range}]";
                    query = "sum(increase(blocky_request_duration_seconds_sum[${range}])) / sum(increase(blocky_request_duration_seconds_count[${range}])) * 1000";
                    format = {
                      type = "number";
                      options.maximumFractionDigits = 2;
                      suffix = " ms";
                    };
                  }
                ];
              };
            };
          }
          {
            PostgreSQL = {
              description = "SQL database service.";
              icon = "postgresql";
              widget = {
                type = "prometheusmetric";
                url = makeServiceLoopbackUrl "prometheus";
                metrics = [
                  {
                    label = "Databases";
                    query = "count(pg_database_size_bytes)";
                    format.type = "number";
                  }
                  {
                    label = "Total size";
                    query = "sum(pg_database_size_bytes)";
                    format.type = "bytes";
                  }
                  {
                    label = "Scrape error";
                    query = "pg_exporter_last_scrape_error";
                    format.type = "text";
                  }
                ];
              };
            };
          }
        ];
      }
    ];
    widgets = [
      {
        greeting = {
          text = "intra.cyran.dev status";
        };
      }
      {
        datetime = {
          text_size = "xl";
          format = {
            timeStyle = "short";
            hourCycle = "h23";
          };
        };
      }
    ];
  };
}
