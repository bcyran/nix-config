{
  config,
  lib,
  ...
}: let
  inherit (lib) types;
  cfg = config.my.configurations.user;

  userCfg = config.my.user;
in {
  options.my.configurations.user = {
    enable = lib.mkEnableOption "user";
    hashedPasswordFile = lib.mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Full path to the file containing user's hashed password.";
    };
    rootHashedPasswordFile = lib.mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Full path to the file containing root's hashed password.";
    };
  };

  config = lib.mkIf cfg.enable {
    users = {
      mutableUsers = cfg.hashedPasswordFile == null || cfg.rootHashedPasswordFile == null;
      users = {
        root = {
          hashedPasswordFile = cfg.rootHashedPasswordFile;
          isSystemUser = true;
        };
        ${config.my.user.name} = {
          inherit (userCfg) shell uid;
          inherit (cfg) hashedPasswordFile;
          isNormalUser = true;
          description = userCfg.fullName;
          extraGroups = userCfg.groups;
        };
      };
    };

    assertions = [
      {
        assertion = !(lib.trivial.xor (cfg.hashedPasswordFile == null) (cfg.rootHashedPasswordFile == null));
        message = "Both `hashedPasswordFile` and `rootHashedPasswordFile` must be set or unset.";
      }
    ];
  };
}
