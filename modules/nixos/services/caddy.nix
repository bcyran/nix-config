{
  inputs,
  pkgs,
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.caddy;
  caddyCfg = config.services.caddy;
  lokiCfg = config.my.services.loki;

  grafanaDashboardsLib = inputs.grafana-dashboards.lib {inherit pkgs;};
  caddyWithPlugins = pkgs.caddy.withPlugins {
    plugins = [
      "github.com/caddy-dns/ovh@v0.0.3"
      "github.com/greenpau/caddy-git@v1.0.9"
    ];
    hash = "sha256-IX93qzCfdWqpRtWvOA3n4fV1CoZCMZ2HCBdu88b2MH0=";
  };

  nixBin = lib.getExe pkgs.nix;
  wwwDir = "/srv/www";
  mkRepoPath = domain: "${wwwDir}/${domain}";
  mkRepoBuildPath = domain: "${mkRepoPath domain}/result";
  mkRepoConfig = domain: cfg: ''
    repo ${domain} {
      base_dir ${wwwDir}
      url ${cfg.repoUrl}
      auth key ${cfg.sshKeyFile} no_strict_host_key_check
      branch ${cfg.branchName}
      webhook ${cfg.updateWebhookConfig}

      post pull exec {
        name Build
        command ${nixBin}
        args build ${mkRepoPath domain} -o ${mkRepoBuildPath domain}
      }
    }
  '';
  mkGitConfig = staticGitHosts:
    lib.optionalString (staticGitHosts != {}) ''
      git {
        ${lib.concatMapAttrsStringSep "\n" mkRepoConfig staticGitHosts}
      }
    '';
  mkGitHostConfig = domain: cfg: ''
    ${domain} {
      route /_update {
        git update repo ${domain}
      }

      route {
        file_server {
          root ${mkRepoBuildPath domain}
        }
      }

      ${my.lib.caddy.mkLogConfig domain}
    }
  '';
  mkGitHostsConfig = staticGitHosts: lib.concatMapAttrsStringSep "\n" mkGitHostConfig staticGitHosts;
in {
  options.my.services.caddy = let
    serviceName = "Caddy web server";
  in {
    enable = lib.mkEnableOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    httpPort = my.lib.options.mkPortOption serviceName 80;
    httpsPort = my.lib.options.mkPortOption serviceName 443;
    adminAddress = my.lib.options.mkAddressOption serviceName;
    adminPort = my.lib.options.mkPortOption serviceName 2019;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
    environmentFile = my.lib.options.mkEnvironmentFileOption serviceName;

    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Extra configuration to add to the Caddyfile.";
    };

    staticGitHosts = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            repoUrl = lib.mkOption {
              type = lib.types.str;
              example = "git@github.com:user/repo.git";
              description = "URL of the Git repository to serve.";
            };
            branchName = lib.mkOption {
              type = lib.types.str;
              default = "production";
              example = "main";
              description = "Name of the branch to serve.";
            };
            sshKeyFile = lib.mkOption {
              type = lib.types.path;
              example = "/path/to/key";
              description = "Path to the SSH key file to use for authentication.";
            };
            updateWebhookConfig = lib.mkOption {
              type = lib.types.str;
              example = "Github X-Hub-Signature-256 secret";
              description = "Configuration for the webhook used to trigger updates.";
            };
          };
        }
      );
      default = {};
      description = "Static Git repositories to serve.";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [cfg.httpPort cfg.httpsPort];
    };

    systemd.tmpfiles.rules = [
      "d '${wwwDir}' 0750 ${caddyCfg.user} ${caddyCfg.group} - -"
    ];

    services = {
      caddy = {
        enable = true;
        package = caddyWithPlugins;
        inherit (cfg) environmentFile;

        globalConfig = ''
          default_bind ${toString cfg.address}
          http_port ${toString cfg.httpPort}
          https_port ${toString cfg.httpsPort}
          admin ${cfg.adminAddress}:${toString cfg.adminPort}

          metrics

          ${mkGitConfig cfg.staticGitHosts}
        '';

        extraConfig = lib.concatStringsSep "\n" [
          cfg.extraConfig
          (mkGitHostsConfig cfg.staticGitHosts)
        ];
      };

      promtail.configuration.scrape_configs = lib.mkIf lokiCfg.enable [
        {
          job_name = "caddy";
          static_configs = [
            {
              targets = ["localhost"];
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

      prometheus.scrapeConfigs = lib.mkIf config.services.prometheus.enable [
        {
          job_name = "caddy";
          static_configs = [
            {
              targets = ["127.0.0.1:${toString cfg.adminPort}"];
            }
          ];
        }
      ];

      grafana = lib.mkIf config.services.grafana.enable {
        settings.panels.disable_sanitize_html = true;

        provision.dashboards.settings.providers = [
          (grafanaDashboardsLib.dashboardEntry {
            name = "caddy";
            path = grafanaDashboardsLib.fetchDashboard {
              name = "caddy";
              id = 20802;
              version = 1;
              hash = "sha256-36tLF4VJJLs6SkTp9RJI84EsixgKYarOH2AOGNArK3E=";
            };
            transformations = grafanaDashboardsLib.fillTemplating [
              {
                key = "DS_PROMETHEUS-INDUMIA";
                value = "Prometheus";
              }
              {
                key = "DS_LOKI-INDUMIA";
                value = "Loki";
              }
            ];
          })
        ];
      };
    };
  };
}
