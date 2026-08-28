{my, ...}: {
  imports = [
    my.inputs.sops-nix.nixosModules.sops
    my.inputs.vpn-confinement.nixosModules.default
    my.inputs.my-private.nixosModules.default
    my.inputs.noctalia-greeter.nixosModules.default

    ./options
    ./configurations
    ./programs
    ./services
    ./presets
    ../common
  ];
}
