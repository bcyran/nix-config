{
  description = "Bazyli's Nix config";

  inputs = {
    # NixOS dependencies.
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

    # Home Manager dependencies.
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
    swww = {
      url = "github:LGFae/swww";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secret management
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    my-secrets = {
      url = "git+ssh://git@github.com/bcyran/nix-secrets.git?ref=main&shallow=1";
      flake = false;
    };
  };

  outputs = inputs: let
    inherit (inputs.nixpkgs) lib;

    # Systems supported by this flake.
    systems = ["x86_64-linux"];

    # Our custom lib.
    myLib = import ./lib {inherit lib;};
  in {
    # Pakcages exported by this flake. Build using `nix build .#package`.
    packages = myLib.forEachSystemPkgs systems inputs.nixpkgs (pkgs: import ./pkgs pkgs);

    # We use `alejandra` as a formatter. Format using `nix fmt`.
    formatter = myLib.forEachSystemPkgs systems inputs.nixpkgs (pkgs: pkgs.alejandra);

    # Overlays exported by this flake. Accessible as `my.overlays`.
    overlays = import ./overlays {inherit inputs;};

    # Lib exported by this flake. Accessible as `my.lib`.
    lib = myLib;

    # NixOS modules exported by this flake. Accessible as `my.nixosModules`.
    # They don't contain specific machine configurations, but rather generic, reusable modules,
    # which can be enabled in specific configurations.
    nixosModules = import ./modules/nixos;

    # Home Manager modules exported by this flake. Accessible as `my.homeManagerModules`.
    # Similarly to `nixosModules`, they contain generic, reusable modules.
    homeManagerModules = import ./modules/home-manager;

    # NixOS configurations exported by this flake.
    # Those configurations mostly just enable selected stuff from `my.nixosModules`.
    # Example usage: `nixos-rebuild switch --flake .#slimbook`.
    nixosConfigurations = lib.mergeAttrsList [
      (myLib.config.mkSystem {
        name = "slimbook";
        system = "x86_64-linux";
        inherit inputs;
        my = inputs.self;
      })
      (myLib.config.mkSystem {
        name = "t480";
        system = "x86_64-linux";
        inherit inputs;
        my = inputs.self;
      })
    ];

    # Home Manager configurations exported by this flake.
    # Those configurations mostly just enable selected stuff from `my.homeManagerModules`.
    # Example usage: `home-manager switch --flake .#bazyli@slimbook`.
    homeConfigurations = lib.mergeAttrsList [
      (myLib.config.mkHome {
        name = "bazyli@slimbook";
        system = "x86_64-linux";
        inherit inputs;
        my = inputs.self;
      })
      (myLib.config.mkHome {
        name = "bazyli@t480";
        system = "x86_64-linux";
        inherit inputs;
        my = inputs.self;
      })
    ];
  };
}
