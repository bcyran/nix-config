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
    domain = my.lib.options.mkDomainOption "${serviceName} GUI";
    environmentFiles = my.lib.options.mkEnvironmentFilesOption serviceName;
    dataDir = my.lib.options.mkDataDirOption serviceName "/var/lib/syncthing";

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
      type = with lib.types; listOf str;
      description = "List of folders to sync.";
      default = [];
    };

    # TODO: Use a secret file once merged: https://github.com/NixOS/nixpkgs/pull/290485.
    hashedPassword = lib.mkOption {
      type = with lib.types; nullOr str;
      description = "Hashed password for the GUI.";
      default = null;
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewallGui [cfg.guiPort];

    services.syncthing = {
      enable = true;
      openDefaultPorts = cfg.openFirewallTransfer;
      guiAddress = "${cfg.guiAddress}:${toString cfg.guiPort}";
      inherit (cfg) dataDir;

      settings = {
        devices = lib.mapAttrs (name: id: {inherit id;}) cfg.devices;
        folders = lib.listToAttrs (map (name: {
            inherit name;
            value = {
              path = "${cfg.dataDir}/${name}";
              devices = builtins.attrNames cfg.devices;
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
      serviceConfig.EnvironmentFile = cfg.environmentFiles;
    };

    services.caddy.virtualHosts = my.lib.caddy.makeReverseProxy {
      inherit (cfg) domain;
      address = cfg.guiAddress;
      port = cfg.guiPort;
      proxyExtraConfig = ''
        header_up Host {upstream_hostport}
      '';
    };
  };
}
