{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.caddy;
  reverseProxyCfg = config.my.services.reverseProxy;

  caddyWithOvhDnsPlugin = my.pkgs.caddy.withPlugins {
    plugins = ["github.com/caddy-dns/ovh@v0.0.3"];
    hash = "sha256-Sy9ZV/rmnfi1aaDfZo8B7dD3JoEMb9onc9swpjQfJNc=";
  };

  makeVirtualHost = domain: vhost: {
    ${domain}.extraConfig = ''
      reverse_proxy ${vhost.backendAddress}:${toString vhost.backendPort}

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

    environmentFiles = lib.mkOption {
      type = with lib.types; listOf path;
      default = [];
      description = "List of paths to the environment files for the service (for secrets).";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = {
      allowedTCPPorts = [reverseProxyCfg.HTTPPort reverseProxyCfg.HTTPSPort];
    };

    services.caddy = {
      enable = true;
      package = caddyWithOvhDnsPlugin;

      globalConfig = ''
        http_port ${toString reverseProxyCfg.HTTPPort}
        https_port ${toString reverseProxyCfg.HTTPSPort}
      '';

      virtualHosts = lib.attrsets.concatMapAttrs makeVirtualHost reverseProxyCfg.virtualHosts;
    };

    systemd.services.caddy.serviceConfig.EnvironmentFile = cfg.environmentFiles;
  };
}
