{
  description = "Bazyli's Nix config";

  inputs = {
    # NixOS
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hardware = {
      url = "github:nixos/nixos-hardware";
    };

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-colors = {
      url = "github:misterio77/nix-colors";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    anyrun = {
      url = "github:anyrun-org/anyrun";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    anyrun-powermenu = {
      url = "github:bcyran/anyrun-powermenu";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprcursor-phinger = {
      url = "github:jappie3/hyprcursor-phinger";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    inherit (self) outputs;
    systems = ["x86_64-linux"];
    forAllSystems = nixpkgs.lib.genAttrs systems;

    # Extend `nixpkgs.lib` with `my` custom lib and return it.
    # Example usage: `lib.my.listDir <dir>`.
    extendLibWithMy = nixpkgs:
      nixpkgs.lib.extend
      (final: prev: {my = import ./lib {lib = final;};} // home-manager.lib);
    lib = extendLibWithMy nixpkgs;
  in {
    packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);
    overlays = import ./overlays {inherit inputs;};
    nixosModules = import ./modules/nixos;
    homeManagerModules = import ./modules/home-manager;

    nixosConfigurations = {
      slimbook = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs lib;};
        modules = [./hosts/slimbook/nixos];
      };
      nixtest = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs lib;};
        modules = [./hosts/nixtest/nixos];
      };
    };

    homeConfigurations = {
      "bazyli@slimbook" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {inherit inputs outputs lib;};
        modules = [./hosts/slimbook/home-manager/bazyli.nix];
      };
      "bazyli@nixtest" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {inherit inputs outputs lib;};
        modules = [./hosts/nixtest/home-manager/bazyli.nix];
      };
    };
  };
}
