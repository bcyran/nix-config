{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.samba;

  mkShare = name: path: {
    "path" = path;
    "public" = "no";
    "writeable" = "yes";
    "valid users" = lib.concatStringsSep " " cfg.validUsers;
    "force user" = cfg.user;
    "force group" = cfg.group;
    "guest ok" = "no";
    "create mask" = "0664";
    "directory mask" = "0775";
  };
in {
  options.my.services.samba = let
    serviceName = "Samba";
  in {
    enable = lib.mkEnableOption serviceName;
    openFirewall = my.lib.options.mkOpenFirewallOption serviceName;

    user = lib.mkOption {
      type = lib.types.str;
      default = "share";
      example = "jan";
      description = "The user to use for the Samba share";
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = "share";
      example = "users";
      description = "The group to use for the Samba share";
    };

    validUsers = lib.mkOption {
      type = with lib.types; listOf str;
      default = [];
      example = ["jan"];
      description = "Users allowed to access the shares";
    };

    shares = lib.mkOption {
      type = with lib.types; attrsOf str;
      example = {
        "share_name" = "/mnt/share_dir";
      };
      description = "A map of share names to directories";
    };
  };

  config = lib.mkIf cfg.enable {
    services.samba = {
      enable = true;
      inherit (cfg) openFirewall;
      settings =
        {
          global = {
            "workgroup" = "WORKGROUP";
            "server string" = "SMB Nix";
            "server role" = "standalone server";
            "log file" = "/var/log/samba/smbd.%m";
            "max log size" = "50";
            "dns proxy" = "no";
            "security" = "user";
            "map to guest" = "Bad User";
          };
        }
        // lib.mapAttrs mkShare cfg.shares;
    };
    users = {
      users."${cfg.user}" = {
        isSystemUser = true;
        inherit (cfg) group;
      };
      groups."${cfg.group}" = {};
    };
  };
}
