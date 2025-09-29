{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.syncthing;
in {
  options.my.services.syncthing = let
    serviceName = "Syncthing";
  in {
    enable = lib.mkEnableOption serviceName;
    guiAddress = my.lib.options.mkAddressOption "${serviceName} GUI";
    guiPort = my.lib.options.mkPortOption "${serviceName} GUI" 8384;
    openFirewallGui = my.lib.options.mkOpenFirewallOption "${serviceName} GUI";
    openFirewallTransfer = my.lib.options.mkOpenFirewallOption "${serviceName} file transfer and discovery";
    reverseProxy = my.lib.options.mkReverseProxyOptions "${serviceName} GUI";
    environmentFiles = my.lib.options.mkEnvironmentFilesOption serviceName;

    keyFile = lib.mkOption {
      type = with lib.types; nullOr path;
      default = null;
      description = "Path to the key file.";
    };

    certFile = lib.mkOption {
      type = with lib.types; nullOr path;
      default = null;
      description = "Path to the certificate file.";
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
              type = nullOr path;
              default = null;
              description = "Path to the folder. Defaults to /var/lib/<name>.";
            };
            type = lib.mkOption {
              type = enum ["sendreceive" "sendonly" "receiveonly" "receiveencrypted"];
              default = "sendreceive";
              description = "Folder type.";
            };
            devices = lib.mkOption {
              type = nullOr (listOf str);
              default = null;
              description = "List of device names. Defaults to service-level devices.";
            };
          };
        });
      description = "List of folders to sync, each as a submodule.";
      default = [];
    };

    # TODO: Use a secret file once merged: https://github.com/NixOS/nixpkgs/pull/290485.
    hashedPassword = lib.mkOption {
      type = with lib.types; nullOr str;
      description = "Hashed password for the GUI.";
      default = null;
    };

    supplementaryGroups = lib.mkOption {
      type = with lib.types; listOf str;
      default = [];
      description = "List of supplementary groups for the syncthing service.";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewallGui [cfg.guiPort];

    services.syncthing = {
      enable = true;
      openDefaultPorts = cfg.openFirewallTransfer;
      guiAddress = "${cfg.guiAddress}:${toString cfg.guiPort}";

      settings = {
        devices = lib.mapAttrs (name: id: {inherit id;}) cfg.devices;
        folders = lib.listToAttrs (map (folder: {
            inherit (folder) name;
            value = {
              inherit (folder) type;
              path =
                lib.trivial.defaultTo "${config.services.syncthing.dataDir}/${folder.name}"
                folder.path;
              devices =
                lib.trivial.defaultTo
                (builtins.attrNames cfg.devices)
                folder.devices;
            };
          })
          cfg.folders);
        gui = {
          theme = "dark";
          user = config.my.user.name;
          password = cfg.hashedPassword;
        };
      };
    };

    systemd.services.syncthing = {
      environment.STNODEFAULTFOLDER = "true";
      serviceConfig = {
        EnvironmentFile = cfg.environmentFiles;
        SupplementaryGroups = cfg.supplementaryGroups;
      };
    };

    my.services.caddy.reverseProxyHosts = lib.optionalAttrs (cfg.reverseProxy.domain != null) {
      ${cfg.reverseProxy.domain} = {
        upstreamAddress = cfg.guiAddress;
        upstreamPort = cfg.guiPort;
        proxyExtraConfig = ''
          header_up Host {upstream_hostport}
        '';
      };
    };
  };
}
