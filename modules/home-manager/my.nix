{inputs, ...}: {
  imports = [
    inputs.nix-colors.homeManagerModules.default
    inputs.nix-index-database.hmModules.nix-index
    inputs.anyrun.homeManagerModules.default
    inputs.hyprcursor-phinger.homeManagerModules.hyprcursor-phinger

    ./configurations
    ./programs
    ./presets
    ./hardware.nix
    ../common/user.nix
  ];
}
