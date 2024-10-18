{my, ...}: {
  imports = [
    my.inputs.sops-nix.nixosModules.sops
    my.inputs.nixos-cosmic.nixosModules.default

    ./configurations
    ./programs
    ./presets
    ../common/user.nix
  ];
}
