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
    systems = ["x86_64-linux"];
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);
    overlays = import ./overlays {inherit inputs;};
    nixosModules = import ./modules/nixos;
    homeManagerModules = import ./modules/home-manager;
    lib = import ./lib {inherit (nixpkgs) lib;};

    nixosConfigurations = {
      slimbook = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          my = self;
          myPkgs = self.packages.x86_64-linux;
        };
        modules = [./hosts/slimbook/nixos];
      };
      nixtest = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          my = self;
          myPkgs = self.packages.x86_64-linux;
        };
        modules = [./hosts/nixtest/nixos];
      };
    };

    homeConfigurations = {
      "bazyli@slimbook" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {
          inherit inputs;
          my = self;
          myPkgs = self.packages.x86_64-linux;
        };
        modules = [./hosts/slimbook/home-manager/bazyli.nix];
      };
      "bazyli@nixtest" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {
          inherit inputs;
          my = self;
          myPkgs = self.packages.x86_64-linux;
        };
        modules = [./hosts/nixtest/home-manager/bazyli.nix];
      };
    };
  };
}
