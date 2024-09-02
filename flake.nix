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

    # Secret management
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    my-secrets = {
      url = "git+ssh://git@github.com/bcyran/secrets-nix.git?ref=main&shallow=1";
      flake = false;
    };
  };

  outputs = inputs: let
    # Systems supported by this flake.
    systems = ["x86_64-linux"];

    # Our custom lib.
    lib = import ./lib {inherit (inputs.nixpkgs) lib;};
  in {
    # Pakcages exported by this flake. Build using `nix build .#package`.
    packages = lib.forEachSystemPkgs systems inputs.nixpkgs (pkgs: import ./pkgs pkgs);

    # We use `alejandra` as a formatter. Format using `nix fmt`.
    formatter = lib.forEachSystemPkgs systems inputs.nixpkgs (pkgs: pkgs.alejandra);

    # Overlays exported by this flake. Accessible as `my.overlays`.
    overlays = import ./overlays {inherit inputs;};

    # Lib exported by this flake. Accessible as `my.lib`.
    inherit lib;

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
    nixosConfigurations = {
      slimbook = lib.config.mkSystem {
        inherit inputs;
        my = inputs.self;
        system = "x86_64-linux";
        modules = [./hosts/slimbook/nixos];
      };
      t480 = lib.config.mkSystem {
        inherit inputs;
        my = inputs.self;
        system = "x86_64-linux";
        modules = [./hosts/t480/nixos];
      };
    };

    # Home Manager configurations exported by this flake.
    # Those configurations mostly just enable selected stuff from `my.homeManagerModules`.
    # Example usage: `home-manager switch --flake .#bazyli@slimbook`.
    homeConfigurations = {
      "bazyli@slimbook" = lib.config.mkHome {
        inherit inputs;
        my = inputs.self;
        system = "x86_64-linux";
        modules = [./hosts/slimbook/home-manager/bazyli.nix];
      };
      "bazyli@t480" = lib.config.mkHome {
        inherit inputs;
        my = inputs.self;
        system = "x86_64-linux";
        modules = [./hosts/t480/home-manager/bazyli.nix];
      };
    };
  };
}
