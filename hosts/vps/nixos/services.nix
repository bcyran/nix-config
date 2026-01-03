{
  my,
  config,
  lib,
  ...
}: let
  caddyCfg = config.services.caddy;
  crowdsecCfg = config.services.crowdsec;

  extraDomain = my.lib.const.domains.extra;
  vpsWgDomain = my.lib.const.wireguard.peers.vps.domain;
  vpsWgAddresses = with my.lib.const.wireguard.peers.vps; [ip "[${ipv6}]"];
in {
  sops.secrets = {
    caddy_env_file = {
      owner = caddyCfg.user;
      reloadUnits = ["caddy.service"];
    };
    deploy_cyran_dev_ssh_key_file = {
      owner = caddyCfg.user;
      reloadUnits = ["caddy.service"];
    };
    crowdsec_console_token_file = {
      owner = crowdsecCfg.user;
      reloadUnits = ["crowdsec.service"];
    };
    crowdsec_capi_credentials_file = {
      owner = crowdsecCfg.user;
      reloadUnits = ["crowdsec.service"];
    };
  };

  my = {
    # This module from my `nix-private` flake enables more websites in the same way as
    # `staticGitHosts` below.
    private.websites.enable = true;
    services = {
      caddy = {
        enable = true;
        address = "0.0.0.0";
        openFirewall = true;
        environmentFile = config.sops.secrets.caddy_env_file.path;
        # This pulls the repo, runs `nix build` and serves the result.
        # Webhook to the /_update endpoint triggers the update.
        staticGitHosts = {
          "cyran.dev" = {
            repoUrl = "git@github.com:bcyran/bazyli-cyran.git";
            sshKeyFile = config.sops.secrets.deploy_cyran_dev_ssh_key_file.path;
            updateWebhookConfig = "Github X-Hub-Signature-256 {$GITHUB_CYRAN_DEV_WEBHOOK_SECRET}";
          };
        };
        reverseProxyHostsCommonExtraConfig = ''
          tls {
            resolvers ${lib.concatStringsSep " " my.lib.const.dns.ips};
            dns ovh {
              endpoint {$OVH_CYRAN_DEV_ENDPOINT}
              application_key {$OVH_CYRAN_DEV_APPLICATION_KEY}
              application_secret {$OVH_CYRAN_DEV_APPLICATION_SECRET}
              consumer_key {$OVH_CYRAN_DEV_CONSUMER_KEY}
            }
          }
        '';
        # Externally available services hosted on atlas (home server).
        reverseProxyHosts = {
          "jellyfin.${extraDomain}" = {
            upstreamAddress = "http://${my.lib.const.wireguard.peers.atlas.ip}";
            upstreamPort = 80;
          };
        };
        reverseProxyHosts = {
          "jellyseerr.${extraDomain}" = {
            upstreamAddress = "http://${my.lib.const.wireguard.peers.atlas.ip}";
            upstreamPort = 80;
          };
        };
      };
      fail2ban.enable = true;
      crowdsec = {
        enable = true;
        consoleTokenFile = config.sops.secrets.crowdsec_console_token_file.path;
        capiCredentialsFile = config.sops.secrets.crowdsec_capi_credentials_file.path;
      };
      prometheus = {
        enable = true;
        reverseProxy = {
          domain = "prometheus.${vpsWgDomain}";
          listenAddresses = vpsWgAddresses;
        };
      };
      loki.enable = true;
      grafana = {
        enable = true;
        reverseProxy = {
          domain = "grafana.${vpsWgDomain}";
          listenAddresses = vpsWgAddresses;
        };
      };
    };
  };
}
