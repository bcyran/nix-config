{my, ...}: {
  imports = [
    my.inputs.sops-nix.nixosModules.sops

    ./configurations
    ./programs
    ./presets
    ../common/user.nix
  ];
}
