{my, ...}: {
  imports = [
    ({modulesPath, ...}: {
      disabledModules = ["${modulesPath}/programs/anyrun.nix"];
    })

    my.inputs.sops-nix.homeManagerModules.sops
    my.inputs.nix-colors.homeManagerModules.default
    my.inputs.nix-index-database.homeModules.nix-index
    my.inputs.hyprcursor-phinger.homeManagerModules.hyprcursor-phinger
    my.inputs.timewall.homeManagerModules.timewall
    my.inputs.anyrun.homeManagerModules.default
    my.inputs.hyprland.homeManagerModules.default

    ./options
    ./configurations
    ./programs
    ./presets
    ../common
  ];
}
