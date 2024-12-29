{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.homepage;
in {
  options.my.services.homepage = {
    enable = lib.mkEnableOption "homepage";

    port = lib.mkOption {
      type = lib.types.int;
      default = 8080;
      description = "The port on which the homepage is accessible.";
    };

    domain = lib.mkOption {
      type = lib.types.str;
      example = "homepage.home.my.tld";
      description = "The domain on which the homepage is accessible.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.homepage-dashboard = {
      enable = true;
      package = my.pkgs.homepage-dashboard;
      openFirewall = true;
      listenPort = cfg.port;

      settings = {
        hideVersion = true;
        statusStyle = "dot";
        theme = "dark";
      };

      services = [
        {
          "Services" = [
            {
              Syncthing = rec {
                description = "File synchronization service.";
                icon = "syncthing";
                href = "https://${config.my.services.syncthing.domain}";
                siteMonitor = href;
              };
            }
            {
              "Home Assistant" = rec {
                description = "Home automation service.";
                icon = "home-assistant";
                href = "https://${config.my.services.home-assistant.domain}";
                siteMonitor = href;
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
                siteMonitor = href;
              };
            }
            {
              Prometheus = rec {
                description = "Server metrics collection.";
                icon = "prometheus";
                href = "https://${config.my.services.prometheus.domain}";
                siteMonitor = href;
              };
            }
          ];
        }
        {
          "Server" = [
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
                  url = "https://${config.my.services.prometheus.domain}";
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
          ];
        }
      ];

      widgets = [
        {
          resources = {
            cpu = true;
            memory = true;
            disk = "/";
            cputemp = true;
            uptime = true;
            units = "metric";
            refresh = 5000;
            diskUnits = "bbytes";
            network = true;
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

    my.services.reverseProxy.virtualHosts.${cfg.domain} = {
      backendAddress = "127.0.0.1";
      backendPort = cfg.port;
    };
  };
}