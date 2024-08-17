{inputs, ...}: {
  imports = [
    inputs.nix-colors.homeManagerModules.default
    inputs.nix-index-database.hmModules.nix-index
    inputs.anyrun.homeManagerModules.default

    ./configurations
    ./programs
    ./presets
    ./hardware.nix
    ../common/user.nix
  ];
}
