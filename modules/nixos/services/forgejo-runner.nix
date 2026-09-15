{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.services.forgejo-runner;
in {
  options.my.services.forgejo-runner = let
    serviceName = "Forgejo runner";
  in {
    enable = lib.mkEnableOption serviceName;

    serverUrl = lib.mkOption {
      type = lib.types.str;
      example = "https://forgejo.example.com";
      description = "The URL of the Forgejo instance to which the runner connects.";
    };

    labels = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "ubuntu-latest:docker://node:current"
        "native:host"
      ];
      description = "Labels used to map jobs to their runtime environment.";
    };

    uuid = lib.mkOption {
      type = lib.types.str;
      example = "c9e50be9-a7c3-4aee-ba35-624c4ff8c519";
      description = "The UUID of the registered runner.";
    };

    tokenFile = lib.mkOption {
      type = lib.types.path;
      example = "/run/secrets/forgejo-runner-token";
      description = "The path to the file containing the runner token.";
    };

    hostPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Extra packages available to jobs running with the host runtime.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.forgejo-runner.instances.default = {
      enable = true;

      settings = {
        runner.labels = cfg.labels;
        server.connections.default = {
          url = cfg.serverUrl;
          inherit (cfg) uuid;
        };
      };

      secrets.server.connections.default.token_url = cfg.tokenFile;

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
  };
}
