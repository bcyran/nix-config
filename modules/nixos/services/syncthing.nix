{
  config,
  lib,
  ...
}: let
  cfg = config.my.services.syncthing;

  guiPort = 8384;
in {
  options.my.services.syncthing = {
    enable = lib.mkEnableOption "syncthing";

    domain = lib.mkOption {
      type = lib.types.str;
      example = "syncthing.home.my.tld";
      description = "The domain on which the web UI is accessible.";
    };

    keyFile = lib.mkOption {
      type = with lib.types; nullOr path;
      default = null;
      description = "Path to the Syncthing key file.";
    };

    certFile = lib.mkOption {
      type = with lib.types; nullOr path;
      default = null;
      description = "Path to the Syncthing certificate file.";
    };

    devices = lib.mkOption {
      type = with lib.types; attrsOf str;
      description = "Mapping of device names to device IDs.";
      default = {};
    };

    folders = lib.mkOption {
      type = with lib.types; listOf str;
      description = "List of folders to sync.";
      default = [];
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = {
      allowedTCPPorts = [guiPort];
    };

    services.syncthing = {
      enable = true;
      openDefaultPorts = true;
      guiAddress = "0.0.0.0:${toString guiPort}";

      settings = {
        devices = lib.mapAttrs (name: id: {inherit id;}) cfg.devices;
        folders = lib.listToAttrs (map (name: {
            inherit name;
            value = {
              path = "/var/lib/syncthing/${name}";
              devices = builtins.attrNames cfg.devices;
            };
          })
          cfg.folders);
        gui = {
          theme = "dark";
          user = config.my.user.name;
          # TODO: Use a secret file once merged: https://github.com/NixOS/nixpkgs/pull/290485.
          password = "$2a$12$16cl3sRqqpClYhSn/Q1rsuA2gsPI0sYPEk6Zs8QTU5oWwlAY0Y8wC";
        };
      };
    };

    systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";

    my.services.reverseProxy.virtualHosts.${cfg.domain} = {
      backendAddress = "127.0.0.1";
      backendPort = guiPort;
    };
  };
}
