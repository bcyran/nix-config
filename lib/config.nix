# The following functions are intended to be used to create NixOS and Home Manager configurations
# relying on this flake. Such configurations are defined in the `hosts` dir of this flake,
# but can be also defined in other flakes using this flake as an input.
# They ensure that `my` (this flake) is always passed to the configuration modules and that
# `my.pkgs` is a set of packages exported by this flake for the target system.
#
# `my` should always refer to this flake. In this flake it's just `self`, but in other flakes
# it will by `inputs.my`.
{
  # Creates a NixOS system configuration.
  mkSystem = {
    inputs,
    my,
    system,
    modules,
    specialArgs ? {},
  }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit modules;
      specialArgs =
        {
          inherit inputs;
          my = my // {pkgs = my.packages.${system};};
        }
        // specialArgs;
    };

  # Creates a Home Manager configuration.
  mkHome = {
    inputs,
    my,
    system,
    modules,
    specialArgs ? {},
  }:
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit modules;
      pkgs = inputs.nixpkgs.legacyPackages."${system}";
      extraSpecialArgs =
        {
          inherit inputs;
          my = my // {pkgs = my.packages.${system};};
        }
        // specialArgs;
    };
}
