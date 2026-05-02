{
  config,
  lib,
  ...
}: let
  inherit (lib) types;
  cfg = config.my.configurations.remoteBuilder;

  userName = "remotebuild";
  groupName = "remotebuild";
in {
  options.my.configurations.remoteBuilder = {
    enable = lib.mkEnableOption "remote builder";

    authorizedKeys = lib.mkOption {
      type = with types; listOf str;
      default = [];
      description = "List of authorized SSH keys for the ${userName} user.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.${userName} = {
      isSystemUser = true;
      group = groupName;
      useDefaultShell = true;

      openssh.authorizedKeys.keys = cfg.authorizedKeys;
    };

    users.groups.${groupName} = {};

    nix.settings.trusted-users = [userName];
  };
}
