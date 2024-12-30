{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.caddy;
  reverseProxyCfg = config.my.services.reverseProxy;
  lokiCfg = config.my.services.loki;

  caddyWithOvhDnsPlugin = my.pkgs.caddy.withPlugins {
    plugins = ["github.com/caddy-dns/ovh@v0.0.3"];
    hash = "sha256-Sy9ZV/rmnfi1aaDfZo8B7dD3JoEMb9onc9swpjQfJNc=";
  };

  makeVirtualHost = domain: vhost: {
    ${domain}.extraConfig = ''
      reverse_proxy ${vhost.backendAddress}:${toString vhost.backendPort}

      log {
        output file /var/log/caddy/access-${domain}.log {
          roll_size 100MiB
          roll_keep 5
          roll_keep_for 2160h
          mode 644
        }
      }

      tls {
        dns ovh {
          endpoint {$OVH_ENDPOINT}
          application_key {$OVH_APPLICATION_KEY}
          application_secret {$OVH_APPLICATION_SECRET}
          consumer_key {$OVH_CONSUMER_KEY}
        }
      }
    '';
  };
in {
  options.my.services.caddy = {
    enable = lib.mkEnableOption "caddy";

    adminPort = lib.mkOption {
      type = lib.types.int;
      default = 2019;
      description = "The port on which the Caddy admin interface is accessible.";
    };

    environmentFiles = lib.mkOption {
      type = with lib.types; listOf path;
      default = [];
      description = "List of paths to the environment files for the service (for secrets).";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = {
      allowedTCPPorts = [reverseProxyCfg.HTTPPort reverseProxyCfg.HTTPSPort cfg.adminPort];
    };

    services = {
      caddy = {
        enable = true;
        package = caddyWithOvhDnsPlugin;

        globalConfig = ''
          http_port ${toString reverseProxyCfg.HTTPPort}
          https_port ${toString reverseProxyCfg.HTTPSPort}
          admin :${toString cfg.adminPort}
        '';

        virtualHosts = lib.attrsets.concatMapAttrs makeVirtualHost reverseProxyCfg.virtualHosts;
      };

      promtail.configuration.scrape_configs = lib.mkIf lokiCfg.enable [
        {
          job_name = "caddy";
          static_configs = [
            {
              targets = ["localhost:${toString cfg.adminPort}"];
              labels = {
                job = "caddy-access";
                agent = "caddy-promtail";
                __path__ = "/var/log/caddy/*.log";
              };
            }
          ];
          pipeline_stages = [
            {
              json = {
                expressions = {
                  timestamp = "ts";
                };
              };
            }
            {
              timestamp = {
                source = "timestamp";
                format = "Unix";
              };
            }
          ];
        }
      ];
    };

    systemd.services.caddy.serviceConfig.EnvironmentFile = cfg.environmentFiles;
  };
}
