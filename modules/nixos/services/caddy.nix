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
      "github.com/caddy-dns/ovh@v1.0.0"
      "github.com/greenpau/caddy-git@v1.0.9"
    ];
    hash = "sha256-etELbHSXm4wRS17t27ghctTtIwfb7XsLN9BgkoOIVH8=";
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
        root ${mkRepoBuildPath domain}
        ${cfg.extraRouteConfig}
        encode zstd gzip
        file_server
      }

      log {
        ${my.lib.caddy.mkLogConfig domain}
      }
    }
  '';
  mkGitHostsConfig = staticGitHosts: lib.concatMapAttrsStringSep "\n" mkGitHostConfig staticGitHosts;

  mkReverseProxyHostConfig = domain: hostCfg: let
    hostExtraConfig = lib.concatStringsSep "\n" [
      cfg.reverseProxyHostsCommonExtraConfig
      hostCfg.extraConfig
    ];
  in {
    inherit (hostCfg) listenAddresses;
    extraConfig = ''
      reverse_proxy ${hostCfg.upstreamAddress}:${toString hostCfg.upstreamPort} {
        ${hostCfg.proxyExtraConfig}
      }

      ${hostExtraConfig}
    '';
    logFormat = my.lib.caddy.mkLogConfig domain;
  };
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
            extraRouteConfig = lib.mkOption {
              type = lib.types.lines;
              default = "";
              example = "try_files {path} /index.html";
              description = "Extra configuration to add to the route block for this host.";
            };
          };
        }
      );
      default = {};
      description = "Static Git repositories to serve.";
    };

    reverseProxyHosts = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            upstreamAddress = lib.mkOption {
              type = lib.types.str;
              example = "127.0.0.1";
              description = "Upstream server to proxy requests to.";
            };
            upstreamPort = lib.mkOption {
              type = lib.types.int;
              example = 8080;
              description = "Port of the upstream server to proxy requests to.";
            };
            listenAddresses = lib.mkOption {
              type = with lib.types; listOf str;
              default = [];
              example = ["10.10.10.10"];
              description = "Addresses to listen on for this host.";
            };
            extraConfig = lib.mkOption {
              type = lib.types.lines;
              default = "";
              description = "Extra configuration to add to the host block.";
            };
            proxyExtraConfig = lib.mkOption {
              type = lib.types.lines;
              default = "";
              description = "Extra configuration to add to the reverse_proxy block.";
            };
          };
        }
      );
      default = {};
      description = "Reverse proxy hosts to serve.";
    };

    reverseProxyHostsCommonExtraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Extra configuration to add to all reverse proxy host blocks.";
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

        # Specifying [::] here causes a crash. However, 0.0.0.0 seems to include [::].
        # See: https://github.com/caddyserver/caddy/issues/5692.
        globalConfig = ''
          default_bind ${cfg.address}
          http_port ${toString cfg.httpPort}
          https_port ${toString cfg.httpsPort}
          admin ${cfg.adminAddress}:${toString cfg.adminPort}

          metrics

          ${mkGitConfig cfg.staticGitHosts}
        '';

        virtualHosts = builtins.mapAttrs mkReverseProxyHostConfig cfg.reverseProxyHosts;

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
              name = "caddy-dashboard";
              id = 22870;
              version = 3;
              hash = "sha256-MgXKJAgplsObtlpAYJs/KIHsZJeuJShMIz+R2ftQL34=";
            };
            transformations = grafanaDashboardsLib.fillTemplating [
              {
                key = "DS_PROMETHEUS";
                value = "Prometheus";
              }
            ];
          })
        ];
      };
    };
  };
}
