# This module is imported by both NixOS and Home Manager modules.
# It needs to be compatible with both.
{
  my,
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types;
in {
  options.my.user = {
    name = mkOption {
      type = types.str;
      description = "Linux username";
      example = "bazyli";
      default = "";
    };
    fullName = mkOption {
      type = types.str;
      description = "Full name of the user";
      example = "Bazyli Cyran";
      default = "";
    };
    email = mkOption {
      type = types.str;
      description = "User's email address";
      example = "bazyli@cyran.dev";
      default = "";
    };
    home = mkOption {
      type = types.str;
      description = "Path to the user's home directory";
      example = "/home/bazyli";
      default = "";
    };
    configDir = mkOption {
      type = types.str;
      description = "Path to the user's dotfiles directory";
      example = "/home/bazyli/nix-config";
      default = "";
    };
    shell = mkOption {
      type = types.package;
      description = "Packate providing the user's shell";
      example = "pkgs.fish";
      default = "";
    };
    uid = mkOption {
      type = types.int;
      description = "Linux user ID";
      example = 1000;
      default = 0;
    };
    groups = mkOption {
      type = types.listOf types.str;
      description = "List of groups the user belongs to";
      example = ["wheel" "users"];
      default = [];
    };
  };

  config = {
    assertions =
      map (attr: my.lib.makeRequiredAssertion config.my.user "my.user" attr)
      (lib.attrNames config.my.user);
  };
}
