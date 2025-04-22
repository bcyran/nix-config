{my, ...}: {
  imports = [
    my.inputs.sops-nix.homeManagerModules.sops
    my.inputs.nix-colors.homeManagerModules.default
    my.inputs.nix-index-database.hmModules.nix-index
    my.inputs.hyprcursor-phinger.homeManagerModules.hyprcursor-phinger
    my.inputs.timewall.homeManagerModules.timewall

    ./options
    ./configurations
    ./programs
    ./presets
    ../common
  ];
}
