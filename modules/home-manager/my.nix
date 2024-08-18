{my, ...}: {
  imports = [
    my.inputs.nix-colors.homeManagerModules.default
    my.inputs.nix-index-database.hmModules.nix-index
    my.inputs.anyrun.homeManagerModules.default
    my.inputs.hyprcursor-phinger.homeManagerModules.hyprcursor-phinger

    ./configurations
    ./programs
    ./presets
    ./hardware.nix
    ../common/user.nix
  ];
}
