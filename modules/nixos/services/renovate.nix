{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.renovate;
in {
  options.my.services.renovate = let
    serviceName = "Renovate dependency updater";
  in {
    enable = lib.mkEnableOption serviceName;

    endpoint = lib.mkOption {
      type = lib.types.str;
      example = "https://forgejo.example.com/api/v1/";
      description = "The URL of the Forgejo API endpoint to which Renovate connects.";
    };

    tokenFile = lib.mkOption {
      type = lib.types.path;
      example = "/run/secrets/renovate-token";
      description = "The path to the file containing the Forgejo API token.";
    };

    schedule = lib.mkOption {
      type = with lib.types; nullOr str;
      default = "*:30";
      example = "*:30";
      description = "How often to run Renovate. See systemd.time(7) for the format.";
    };

    settings = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Extra Renovate configuration merged into the global settings.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.renovate = {
      enable = true;
      inherit (cfg) schedule;
      runtimePackages = with pkgs; [nix];
      settings =
        {
          platform = "forgejo";
          inherit (cfg) endpoint;
          autodiscover = true;
        }
        // cfg.settings;
      credentials = {
        RENOVATE_TOKEN = cfg.tokenFile;
      };
    };
  };
}
