{
  my,
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.services.nextcloud-context-agent;
  nextcloudCfg = config.my.services.nextcloud;

  appId = "context_agent";
  # renovate: datasource=docker packageName=ghcr.io/nextcloud/context_agent
  imageVersion = "2.11.0";
  daemonName = "manual_install";
  nextcloudUrl = "https://${nextcloudCfg.domain}";
  dataDir = "/var/lib/nextcloud-context-agent";
  uid = 2010;

  # Mirrors the app's appinfo/info.xml; the secret is added at runtime.
  appInfo = pkgs.writeText "nextcloud-context-agent-app-info.json" (builtins.toJSON {
    id = appId;
    name = "Nextcloud Context Agent";
    daemon_config_name = daemonName;
    version = imageVersion;
    inherit (cfg) port;
    routes = [
      {
        url = "^/mcp";
        verb = "POST,GET,DELETE";
        access_level = "USER";
        headers_to_exclude = [];
      }
    ];
  });

  occ = "${config.services.nextcloud.occ}/bin/nextcloud-occ";
  containerService = "${config.virtualisation.oci-containers.containers.nextcloud-context-agent.serviceName}.service";
in {
  options.my.services.nextcloud-context-agent = let
    serviceName = "Nextcloud Context Agent";
  in {
    enable = lib.mkEnableOption serviceName;
    user = my.lib.options.mkUserOption serviceName;
    group = my.lib.options.mkGroupOption serviceName;
    address = my.lib.options.mkAddressOption serviceName;
    port = my.lib.options.mkPortOption serviceName 9081;
    # Must contain `APP_SECRET`, the secret shared between AppAPI and the ExApp.
    environmentFile = my.lib.options.mkEnvironmentFileOption serviceName;
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      assertions = [
        {
          assertion = nextcloudCfg.enable;
          message = "my.services.nextcloud-context-agent requires my.services.nextcloud to be enabled.";
        }
        {
          assertion = cfg.environmentFile != null;
          message = "my.services.nextcloud-context-agent.environmentFile must be set (it provides APP_SECRET).";
        }
      ];

      virtualisation.oci-containers.containers.nextcloud-context-agent = {
        image = "ghcr.io/nextcloud/context_agent:${imageVersion}";
        autoStart = true;
        ports = ["${cfg.address}:${toString cfg.port}:${toString cfg.port}"];
        environment = {
          APP_ID = appId;
          APP_VERSION = imageVersion;
          APP_HOST = "0.0.0.0";
          APP_PORT = toString cfg.port;
          NEXTCLOUD_URL = nextcloudUrl;
          COMPUTE_DEVICE = "CPU";
        };
        environmentFiles = lib.optional (cfg.environmentFile != null) cfg.environmentFile;
        # The ExApp calls Nextcloud through Caddy on the host's loopback.
        extraOptions =
          my.lib.ociContainers.mkLoopbackNetworkOptions [config.my.services.caddy.httpsPort]
          ++ [
            "--add-host=${nextcloudCfg.domain}:127.0.0.1"
            "--cap-drop=ALL"
            "--security-opt=no-new-privileges"
          ];
        podman.user = cfg.user;
      };

      # Registers the manually deployed ExApp in AppAPI. Re-registers it when
      # the app info (version, routes, port) changes.
      systemd.services.nextcloud-context-agent-register = {
        description = "Register Nextcloud Context Agent ExApp";
        wantedBy = ["multi-user.target"];
        requires = ["nextcloud-setup.service" containerService];
        after = ["nextcloud-setup.service" "phpfpm-nextcloud.service" "caddy.service" containerService];
        path = [pkgs.curl pkgs.gnugrep pkgs.jq];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          User = "nextcloud";
          StateDirectory = "nextcloud-context-agent-register";
          EnvironmentFile = cfg.environmentFile;
        };
        script = ''
          ${occ} app_api:daemon:register ${daemonName} "Manual Install" manual-install http ${cfg.address} ${nextcloudUrl}

          stamp="$STATE_DIRECTORY/registered"
          installed=$(${occ} app_api:app:list | grep "^${appId} " || true)
          if [[ -n "$installed" && "$(cat "$stamp" 2>/dev/null)" == "${appInfo}" ]]; then
            exit 0
          fi
          if [[ -n "$installed" ]]; then
            ${occ} app_api:app:unregister ${appId} --silent --force
          fi

          for _ in $(seq 60); do
            curl -fsS http://${cfg.address}:${toString cfg.port}/heartbeat >/dev/null && break
            sleep 2
          done

          json=$(jq -c --arg secret "$APP_SECRET" '.secret = $secret' ${appInfo})
          ${occ} app_api:app:register ${appId} ${daemonName} --json-info "$json" --wait-finish
          echo "${appInfo}" > "$stamp"
        '';
      };
    }

    (my.lib.ociContainers.mkRootlessPodmanUser {
      inherit (cfg) user group;
      home = dataDir;
      inherit uid;
    })
  ]);
}
