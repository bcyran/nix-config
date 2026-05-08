{
  config,
  lib,
  my,
  ...
}: let
  inherit (lib) types mkEnableOption mkOption;
  cfg = config.my.configurations.distributedBuilds;
in {
  options.my.configurations.distributedBuilds = {
    enable = mkEnableOption "distributed builds";

    buildMachines = mkOption {
      type = with types; listOf attrs;
      default = [
        {
          hostName = my.lib.const.lan.devices.atlas.domain;
          system = "x86_64-linux";
          sshUser = my.lib.const.users.remoteBuild;
          sshKey = "/root/.ssh/id_ed25519";
          supportedFeatures = ["nixos-test" "big-parallel" "kvm"];
          maxJobs = 12;
          speedFactor = 1;
        }
      ];
      description = "List of build machines to use for distributed builds.";
    };
  };

  config = lib.mkIf cfg.enable {
    nix = {
      distributedBuilds = true;
      settings.builders-use-substitutes = true;
      inherit (cfg) buildMachines;
    };
  };
}
