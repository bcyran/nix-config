{config, ...}: let
  servicesCfg = config.my.services;
  makeServiceDomainUrl = serviceName: "https://${servicesCfg.${serviceName}.domain}";
  makeLoopbackUrl = port: "http://127.0.0.1:${toString port}";
  makeServiceLoopbackUrl = serviceName: makeLoopbackUrl servicesCfg.${serviceName}.port;
in {
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
                url = makeServiceLoopbackUrl "glances";
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
            Hoarder = rec {
              description = "Bookmark manager.";
              icon = "hoarder";
              href = makeServiceDomainUrl "hoarder";
              siteMonitor = makeServiceLoopbackUrl "hoarder";
              widget = {
                type = "customapi";
                url = "${siteMonitor}/api/v1/bookmarks?limit=1";
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
              href = makeServiceDomainUrl "open-webui";
              siteMonitor = makeServiceLoopbackUrl "open-webui";
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
            Meilisearch = rec {
              description = "Search engine service.";
              icon = "https://raw.githubusercontent.com/meilisearch/meilisearch/372f4fc924f36319c921fd36fbdc354d96b1d974/assets/logo.svg";
              siteMonitor = makeServiceLoopbackUrl "meilisearch";
              widget = {
                type = "customapi";
                url = "${siteMonitor}/stats";
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
            Chromium = rec {
              description = "Headless browser service.";
              icon = "chromium";
              siteMonitor = makeServiceLoopbackUrl "chromium";
              widget = {
                type = "customapi";
                url = "${siteMonitor}/json";
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
