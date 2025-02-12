{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.hoarder;
  meiliCfg = config.my.services.meilisearch;
  chromiumCfg = config.my.services.chromium;
  ollamaCfg = config.my.services.ollama;

  hoarderVersion = "0.22.0";
in {
  options = {
    my.services.hoarder = let
      serviceName = "Hoarder";
    in {
      enable = lib.mkEnableOption serviceName;
      address = my.lib.options.mkAddressOption serviceName;
      port = my.lib.options.mkPortOption serviceName 8083;
      domain = my.lib.options.mkDomainOption serviceName;
      openFirewall = my.lib.options.mkOpenFirewallOption serviceName;
      environmentFiles = my.lib.options.mkEnvironmentFilesOption serviceName;
      dataDir = my.lib.options.mkDataDirOption serviceName "/var/lib/hoarder";

      llm = lib.mkOption {
        type = with lib.types; nullOr str;
        default = null;
        example = "gemma:2b";
        description = "The model to use for tags inference.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];

    virtualisation.oci-containers.containers.hoarder = {
      image = "ghcr.io/hoarder-app/hoarder:${hoarderVersion}";
      autoStart = true;
      ports = ["${cfg.address}:${toString cfg.port}:3000"];
      volumes = [
        "${cfg.dataDir}:/data"
      ];
      environment = let
        loopback = "10.0.2.2";
      in
        {
          DATA_DIR = "/data";
          NEXTAUTH_URL = "https://${cfg.domain}";
        }
        // lib.optionalAttrs meiliCfg.enable {
          MEILI_ADDR = "http://${loopback}:${toString meiliCfg.port}";
        }
        // lib.optionalAttrs chromiumCfg.enable {
          BROWSER_WEB_URL = "http://${loopback}:${toString chromiumCfg.port}";
        }
        // lib.optionalAttrs (cfg.llm != null && ollamaCfg.enable) {
          OLLAMA_BASE_URL = "http://${loopback}:${toString ollamaCfg.port}";
          OLLAMA_KEEP_ALIVE = "1m";
          INFERENCE_TEXT_MODEL = cfg.llm;
          INFERENCE_JOB_TIMEOUT_SEC = "180";
          INFERENCE_CONTEXT_LENGTH = "2048";
        };
      extraOptions = [
        # Expose host's loopback interface in the container as 10.0.2.2.
        "--network=slirp4netns:allow_host_loopback=true"
      ];
      inherit (cfg) environmentFiles;
    };

    systemd.tmpfiles.rules = [
      "d '${cfg.dataDir}' 0750 root root - -"
    ];

    my.services.caddy.reverseProxyHosts = lib.optionalAttrs (cfg.domain != null) {
      ${cfg.domain} = {
        upstreamAddress = cfg.address;
        upstreamPort = cfg.port;
      };
    };
  };
}
