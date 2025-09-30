{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.my.programs.syncthing;
in {
  options.my.programs.syncthing = {
    enable = lib.mkEnableOption "syncthing";

    keyFile = lib.mkOption {
      type = with lib.types; nullOr path;
      default = null;
      description = "Path to the file containing the Syncthing key.";
    };
    certFile = lib.mkOption {
      type = with lib.types; nullOr path;
      default = null;
      description = "Path to the file containing the Syncthing certificate.";
    };
    passwordFile = lib.mkOption {
      type = with lib.types; nullOr path;
      default = null;
      description = "Path to the file containing the Syncthing GUI password file.";
    };

    devices = lib.mkOption {
      type = with lib.types; attrsOf str;
      description = "Mapping of device names to device IDs.";
      default = {};
    };

    folders = lib.mkOption {
      type = with lib.types;
        listOf (submodule {
          options = {
            name = lib.mkOption {
              type = str;
              description = "Name of the folder.";
            };
            path = lib.mkOption {
              type = str;
              description = "Path to the folder.";
            };
            type = lib.mkOption {
              type = enum ["sendreceive" "sendonly" "receiveonly" "receiveencrypted"];
              default = "sendreceive";
              description = "Folder type.";
            };
            devices = lib.mkOption {
              type = nullOr (listOf str);
              default = null;
              description = "List of device names. Defaults to all configured devices.";
            };
          };
        });
      description = "List of folders to sync, each as a submodule.";
      default = [];
    };
  };

  config = lib.mkIf cfg.enable {
    services.syncthing = {
      enable = true;

      key = cfg.keyFile;
      cert = cfg.certFile;
      inherit (cfg) passwordFile;

      settings = {
        devices = lib.mapAttrs (name: id: {inherit id;}) cfg.devices;
        folders = lib.listToAttrs (map (folder: {
            inherit (folder) name;
            value = {
              inherit (folder) path type;
              devices =
                lib.trivial.defaultTo
                (builtins.attrNames cfg.devices)
                folder.devices;
            };
          })
          cfg.folders);
        options = {
          urAccepted = -1;
        };
      };

      tray = {
        enable = true;
        # For some reason syncthingtray-minimal always starts before the tray...
        package = pkgs.syncthingtray;
      };
    };
  };
}
