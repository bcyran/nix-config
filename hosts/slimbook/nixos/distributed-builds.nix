{my, ...}: {
  nix = {
    distributedBuilds = true;
    settings.builders-use-substitutes = true;

    buildMachines = [
      {
        hostName = my.lib.const.lan.devices.atlas.domain;
        system = "x86_64-linux";
        sshUser = "remotebuild";
        sshKey = "/root/.ssh/id_ed25519";
        supportedFeatures = ["nixos-test" "big-parallel" "kvm"];
        maxJobs = 12;
        speedFactor = 1;
      }
    ];
  };
}
