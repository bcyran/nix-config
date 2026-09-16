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

    credentials = lib.mkOption {
      type = lib.types.attrsOf lib.types.path;
      default = {};
      example = {
        RENOVATE_TOKEN = "/run/secrets/renovate-token";
      };
      description = "Credential files to pass to the Renovate service. Each attribute name is the environment variable and the value is the file path.";
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
      inherit (cfg) schedule credentials;
      runtimePackages = with pkgs; [nix];
      settings =
        {
          platform = "forgejo";
          inherit (cfg) endpoint;
          autodiscover = true;
        }
        // cfg.settings;
    };
  };
}
