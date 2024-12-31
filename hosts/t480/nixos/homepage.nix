{config, ...}: {
  services.homepage-dashboard = {
    settings = {
      hideVersion = true;
      statusStyle = "dot";
      theme = "dark";

      layout = {
        "Hardware status" = {
          style = "row";
          columns = 3;
        };
      };
    };

    services = [
      {
        "Hardware status" = let
          makeGlancesWidget = title: metricName: {
            "${title}" = {
              widget = {
                type = "glances";
                url = "http://127.0.0.1:${toString config.my.services.glances.port}";
                version = "4";
                metric = metricName;
                refreshInterval = 3000;
              };
            };
          };
        in [
          (makeGlancesWidget "CPU" "cpu")
          (makeGlancesWidget "Memory" "memory")
          (makeGlancesWidget "Network" "network:enp0s31f6")
          (makeGlancesWidget "Processes" "process")
          (makeGlancesWidget "Disk I/O" "disk:nvme0n1")
          (makeGlancesWidget "Root FS" "fs:/")
        ];
      }
      {
        "Applications" = [
          {
            "Home Assistant" = {
              description = "Home automation service.";
              icon = "home-assistant";
              href = "https://${config.my.services.home-assistant.domain}";
              siteMonitor = "http://127.0.0.1:${toString config.my.services.home-assistant.port}";
              widget = {
                type = "homeassistant";
                url = "https://${config.my.services.home-assistant.domain}";
                key = "{{HOMEPAGE_VAR_HASS_API_TOKEN}}";
                fields = ["people_home" "lights_on"];
              };
            };
          }
          {
            Syncthing = {
              description = "File synchronization service.";
              icon = "syncthing";
              href = "https://${config.my.services.syncthing.domain}";
              siteMonitor = "http://127.0.0.1:${toString config.my.services.syncthing.guiPort}";
              widget = {
                type = "customapi";
                url = "https://${config.my.services.syncthing.domain}/rest/db/completion";
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
            "Uptime Kuma" = {
              description = "Service uptime monitoring.";
              icon = "uptime-kuma";
              href = "https://${config.my.services.uptime-kuma.domain}/status/external";
              siteMonitor = "http://127.0.0.1:${toString config.my.services.uptime-kuma.port}";
              widget = {
                type = "uptimekuma";
                url = "http://127.0.0.1:${toString config.my.services.uptime-kuma.port}";
                slug = "external";
              };
            };
          }
          {
            "Speedtest Tracker" = {
              description = "Continuous internet speed monitoring.";
              icon = "myspeed";
              href = "https://${config.my.services.speedtest-tracker.domain}";
              siteMonitor = "http://127.0.0.1:${toString config.my.services.speedtest-tracker.port}";
              widget = {
                type = "speedtest";
                url = "http://127.0.0.1:${toString config.my.services.speedtest-tracker.port}";
              };
            };
          }
          {
            Hoarder = {
              description = "Bookmark manager.";
              icon = "hoarder";
              href = "https://${config.my.services.hoarder.domain}";
              siteMonitor = "http://127.0.0.1:${toString config.my.services.hoarder.port}";
              widget = {
                type = "customapi";
                url = "http://127.0.0.1:${toString config.my.services.hoarder.port}/api/v1/bookmarks?limit=1";
                headers = {
                  "Authorization" = "Bearer {{HOMEPAGE_VAR_HOARDER_API_KEY}}";
                };
                mappings = [
                  {
                    field = {
                      bookmarks = {
                        "0" = "createdAt";
                      };
                    };
                    format = "relativeDate";
                    label = "Last bookmark";
                  }
                ];
              };
            };
          }
          {
            "Open WebUI" = {
              description = "OpenAI API service.";
              icon = "https://docs.openwebui.com/img/logo-dark.png";
              href = "https://${config.my.services.open-webui.domain}";
              siteMonitor = "http://127.0.0.1:${toString config.my.services.open-webui.port}";
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
              href = "https://${config.my.services.grafana.domain}";
              siteMonitor = "http://127.0.0.1:${toString config.my.services.grafana.port}";
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
              href = "https://${config.my.services.prometheus.domain}";
              siteMonitor = "http://127.0.0.1:${toString config.my.services.prometheus.port}";
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
              href = "https://${config.my.services.glances.domain}";
              siteMonitor = "http://127.0.0.1:${toString config.my.services.glances.port}";
            };
          }
          {
            Loki = {
              description = "Log aggregation service.";
              icon = "https://grafana.com/static/img/logos/logo-loki.svg";
              siteMonitor = "http://127.0.0.1:${toString config.my.services.loki.lokiPort}/ready";
            };
          }
          {
            Promtail = {
              description = "Log collector.";
              icon = "https://grafana.com/static/img/logos/logo-loki.svg";
              siteMonitor = "http://127.0.0.1:${toString config.my.services.loki.promtailPort}/ready";
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
              siteMonitor = "http://127.0.0.1:${toString config.my.services.caddy.adminPort}/reverse_proxy/upstreams";
              widget = {
                type = "caddy";
                url = "http://127.0.0.1:${toString config.my.services.caddy.adminPort}";
              };
            };
          }
          {
            Blocky = {
              description = "DNS server with ad blocking.";
              icon = "blocky";
              siteMonitor = "http://127.0.0.1:${toString config.my.services.blocky.httpPort}";
              widget = {
                type = "prometheusmetric";
                url = "http://127.0.0.1:${toString config.my.services.prometheus.port}";
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
                    query = "sum(increase(blocky_request_duration_ms_sum[${range}])) / sum(increase(blocky_request_duration_ms_count[${range}]))";
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
            Tailscale = {
              description = "VPN service.";
              icon = "tailscale";
              widget = {
                type = "tailscale";
                deviceid = "nqHmw1Tgjs11CNTRL";
                key = "{{HOMEPAGE_VAR_TAILSCALE_API_TOKEN}}";
              };
            };
          }
          {
            Ollama = {
              description = "LLM API service.";
              icon = "ollama";
              siteMonitor = "http://127.0.0.1:${toString config.my.services.ollama.port}";
              widget = {
                type = "customapi";
                url = "http://127.0.0.1:${toString config.my.services.ollama.port}/api/ps";
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
            Meilisearch = {
              description = "Search engine service.";
              icon = "https://raw.githubusercontent.com/meilisearch/meilisearch/372f4fc924f36319c921fd36fbdc354d96b1d974/assets/logo.svg";
              siteMonitor = "http://127.0.0.1:${toString config.my.services.meilisearch.port}";
              widget = {
                type = "customapi";
                url = "http://127.0.0.1:${toString config.my.services.meilisearch.port}/stats";
                headers = {
                  "Authorization" = "Bearer {{HOMEPAGE_VAR_MEILISEARCH_API_KEY}}";
                };
                mappings = [
                  {
                    field = "indexes";
                    label = "Indexes";
                    format = "size";
                  }
                  {
                    field = "databaseSize";
                    label = "Total size";
                    format = "bytes";
                  }
                ];
              };
            };
          }
          {
            Chromium = {
              description = "Headless browser service.";
              icon = "chromium";
              siteMonitor = "http://127.0.0.1:${toString config.my.services.chromium.internalPort}";
              widget = {
                type = "customapi";
                url = "http://127.0.0.1:${toString config.my.services.chromium.internalPort}/json";
                mappings = [
                  {
                    label = "Open tabs";
                    format = "size";
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
