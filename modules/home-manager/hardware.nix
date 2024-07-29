{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types;
in {
  options.my.hardware = {
    monitors = mkOption {
      type = types.listOf (
        types.submodule {
          options = {
            description = mkOption {
              type = types.str;
              example = "Dell Inc. DELL P2421D ...";
            };
            output = mkOption {
              type = types.str;
              example = "DP-1";
            };
            altOutput = mkOption {
              type = types.nullOr types.str;
              default = null;
              example = "DP-7";
            };
            width = mkOption {
              type = types.int;
              example = 1920;
            };
            height = mkOption {
              type = types.int;
              example = 1080;
            };
            refreshRate = mkOption {
              type = types.int;
              default = 60;
            };
            x = mkOption {
              type = types.int;
              default = 0;
            };
            y = mkOption {
              type = types.int;
              default = 0;
            };
            scale = mkOption {
              type = types.float;
              default = 1.0;
            };
            transform = mkOption {
              type = types.int;
              default = 0;
            };
            enabled = mkOption {
              type = types.bool;
              default = true;
            };
            id_by_output = mkOption {
              type = types.bool;
              default = false;
            };
          };
        }
      );
      default = [];
    };
    networkInterfaces = {
      wired = mkOption {
        type = types.str;
        example = "enp44s0";
      };
      wireless = mkOption {
        type = types.str;
        example = "wlo1";
      };
    };
  };
  config = {
    assertions = [
      {
        assertion = (lib.length config.my.hardware.monitors) == 3;
        message = "Exactly 3 monitors are required.";
      }
    ];
  };
}
