{my, ...}: {
  imports = [
    my.inputs.sops-nix.nixosModules.sops
    my.inputs.nixos-cosmic.nixosModules.default

    ./options
    ./configurations
    ./programs
    ./services
    ./presets
    ../common/user.nix
  ];
}
