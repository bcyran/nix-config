{
  config,
  lib,
  ...
}: let
  cfg = config.my.services.hoarder;
  meiliCfg = config.my.services.meilisearch;
  chromiumCfg = config.my.services.chromium;

  hoarderVersion = "0.20.0";
  containerName = "hoarder";
  serviceName = "${config.virtualisation.oci-containers.backend}-${containerName}";
  dataDir = "/var/lib/hoarder";
in {
  options = {
    my.services.hoarder = {
      enable = lib.mkEnableOption "hoarder";

      port = lib.mkOption {
        type = lib.types.int;
        default = 8083;
        description = "The port on which the Hoarder is accessible.";
      };

      domain = lib.mkOption {
        type = lib.types.str;
        example = "hoarder.home.my.tld";
        description = "The domain on which the web UI is accessible.";
      };

      environmentFiles = lib.mkOption {
        type = with lib.types; listOf path;
        example = ["/path/to/env/file"];
        description = "The paths to the environment file.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [cfg.port];

    # The container doesn't have access to the host's network.
    # We could just use the host network but then we are stuck with occupying the 3000 port
    # because there's not way to change it.
    # Other option is to use a special address `host.containers.internal` that points to the
    # host's IP. This works but we need to remember that the traffic will come through the
    # podman's network interface. Host services will need to listen on 0.0.0.0, not loopback,
    # and the ports need to be opened in the firewall.
    virtualisation.oci-containers.containers.${containerName} = {
      image = "ghcr.io/hoarder-app/hoarder:${hoarderVersion}";
      autoStart = true;
      ports = ["127.0.0.1:${toString cfg.port}:3000"];
      volumes = [
        "${dataDir}:/data"
      ];
      environment =
        {
          DATA_DIR = "/data";
          NEXTAUTH_URL = "https://${cfg.domain}";
        }
        // lib.optionalAttrs meiliCfg.enable {
          MEILI_ADDR = "http://host.containers.internal:${toString meiliCfg.port}";
        }
        // lib.optionalAttrs chromiumCfg.enable {
          BROWSER_WEB_URL = "http://host.containers.internal:${toString chromiumCfg.externalPort}";
        };
      extraOptions = [
        "--add-host=host.containers.internal:host-gateway"
      ];
      inherit (cfg) environmentFiles;
    };

    systemd.services.${serviceName}.preStart = ''
      mkdir -p ${dataDir}
    '';

    my.services.reverseProxy.virtualHosts.${cfg.domain} = {
      backendAddress = "127.0.0.1";
      backendPort = cfg.port;
    };
  };
}
