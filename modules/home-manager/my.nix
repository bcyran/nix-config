{my, ...}: {
  imports = [
    my.inputs.sops-nix.homeManagerModules.sops
    my.inputs.nix-index-database.homeModules.nix-index
    my.inputs.hyprcursor-phinger.homeManagerModules.hyprcursor-phinger
    my.inputs.noctalia.homeModules.default
    my.inputs.timewall.homeManagerModules.timewall
    my.inputs.agent-skills.homeManagerModules.default

    ./options
    ./configurations
    ./programs
    ./presets
    ../common
  ];
}
