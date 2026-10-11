{
  my,
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.services.forgejo-runner;

  # Dedicated unprivileged user that runs both the runner daemon and the
  # rootless Podman containers it spawns for jobs.
  uid = 2008;
  homeDir = "/var/lib/forgejo-runner";
  cacheDir = "/var/cache/forgejo-runner";

  # This address inside of the containers is routed to the host.
  pastaHostGateway = "169.254.1.2";

  routedConnections = builtins.attrValues (lib.filterAttrs (_: c: c.routeToHost) cfg.connections);

  extractHostname = url: lib.head (lib.splitString "/" (lib.last (lib.splitString "://" url)));
in {
  options.my.services.forgejo-runner = let
    serviceName = "Forgejo runner";
  in {
    enable = lib.mkEnableOption serviceName;
    user = my.lib.options.mkUserOption serviceName;
    group = my.lib.options.mkGroupOption serviceName;

    connections = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          url = lib.mkOption {
            type = lib.types.str;
            example = "https://forgejo.example.com";
            description = "The URL of the Forgejo instance to which the runner connects.";
          };

          uuid = lib.mkOption {
            type = lib.types.str;
            example = "c9e50be9-a7c3-4aee-ba35-624c4ff8c519";
            description = "The UUID of the registered runner for this connection.";
          };

          tokenFile = lib.mkOption {
            type = lib.types.path;
            example = "/run/secrets/forgejo-runner-token";
            description = "The path to the file containing the runner token for this connection.";
          };

          routeToHost = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Whether to route this connection's hostname to the localhost.";
          };
        };
      });
      default = {};
      description = "Forgejo instances this runner registers with and fetches jobs from, keyed by a name for the connection.";
    };

    labels = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "ubuntu-24.04:docker://ghcr.io/catthehacker/ubuntu:act-24.04"
        "ubuntu-latest:docker://ghcr.io/catthehacker/ubuntu:act-latest"
        "rust-24.04:docker://ghcr.io/catthehacker/ubuntu:rust-24.04"
        "rust-latest:docker://ghcr.io/catthehacker/ubuntu:rust-latest"
        "native:host"
      ];
      description = "Labels used to map jobs to their runtime environment.";
    };

    hostPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Extra packages available to jobs running with the host runtime.";
    };

    capacity = lib.mkOption {
      type = lib.types.int;
      default = 4;
      description = "The maximum number of concurrent jobs the runner can handle.";
    };

    cacheProxyPort = my.lib.options.mkPortOption "Forgejo runner cache proxy" 4010;
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      services.forgejo-runner.instances.default = {
        enable = true;
        runtimes = {
          # Rootless Podman is wired up below; do not let the nixpkgs module add
          # the rootful `podman` group/socket dependencies.
          podman = false;
          docker = false;
          host = true;
        };

        settings = {
          container.options =
            lib.mkIf (routedConnections != [])
            (lib.concatMapStringsSep " "
              (c: "--add-host=${extractHostname c.url}:${pastaHostGateway}")
              routedConnections);
          cache = {
            enabled = true;
            dir = cacheDir;
            proxy_port = cfg.cacheProxyPort;
            actions_cache_url_override = "http://${pastaHostGateway}:${toString cfg.cacheProxyPort}";
          };
          runner = {
            inherit (cfg) labels capacity;
          };
          server.connections =
            lib.mapAttrs (_: c: {
              inherit (c) url uuid;
            })
            cfg.connections;
        };

        secrets.server.connections =
          lib.mapAttrs (_: c: {token_url = c.tokenFile;})
          cfg.connections;

        hostPackages = with pkgs;
          [
            alejandra
            bash
            coreutils
            curl
            dix
            gawk
            gnused
            just
            jq
            nix
            nodejs
            openssh
            statix
            wget
          ]
          ++ cfg.hostPackages;
      };

      systemd.services = {
        forgejo-runner-default = {
          after = ["user@${toString uid}.service"];
          wants = ["user@${toString uid}.service"];
          environment = {
            # Connect to the user's rootless Podman socket instead of the rootful one.
            DOCKER_HOST = "unix:///run/user/${toString uid}/podman/podman.sock";
            XDG_RUNTIME_DIR = "/run/user/${toString uid}";
          };
          unitConfig.RequiresMountsFor = "/var/lib/containers/rootless/${toString uid}";
          serviceConfig = {
            # Run the daemon as a static unprivileged user so it shares the
            # rootless Podman socket and its rootless container storage.
            DynamicUser = lib.mkForce false;
            User = lib.mkForce cfg.user;
            Group = lib.mkForce cfg.group;
            # ExecPaths only exists to work around the id-mapped noexec mounts
            # used with DynamicUser; it is unnecessary for a regular user.
            ExecPaths = lib.mkForce [];
            CacheDirectory = "forgejo-runner";
          };
        };
      };
    }

    (my.lib.ociContainers.mkRootlessPodmanUser {
      inherit (cfg) user group;
      home = homeDir;
      inherit uid;
    })
  ]);
}
