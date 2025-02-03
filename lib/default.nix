{lib}: rec {
  # NixOS and Home Manager configuration utilities.
  config = import ./config.nix {inherit lib;};

  # Utilities for creating custom options.
  options = import ./options.nix {inherit lib;};

  # Utilities related to NetworkManager.
  nm = import ./nm.nix;

  # forEachSystemPkgs :: [<system>] -> <nixpkgs> -> (<packages> -> <attrs>) -> <attrs>
  #
  # Generates attributes for each system in `systems` using `f` with packages for that system
  # passed as an argument.
  forEachSystemPkgs = systems: nixpkgs: f:
    nixpkgs.lib.genAttrs systems
    (system: f nixpkgs.legacyPackages.${system});

  # listDir :: path -> [string]
  #
  # Returns a list of names of files (and dirs) in the given directory.
  listDir = dir: (builtins.attrNames (builtins.readDir dir));

  # makeAbsolute :: path -> [string] -> [path]
  #
  # Returns a list of absolute paths of `children` in `parent`.
  makeAbsolute = parent: children:
    map (child: parent + "/${child}") children;

  # listDirModules :: path -> [path]
  #
  # Returns a list of absolute paths of files in `dir`, omitting `default.nix`.
  listDirModules = dir:
    makeAbsolute dir (
      builtins.filter (filename: filename != "default.nix")
      (listDir dir)
    );

  # isFalsy :: anything -> bool
  #
  # Returns true if `x` is falsy, false otherwise.
  isFalsy = x: x == false || x == null || x == "" || x == 0 || x == [] || x == {};

  # makeRequiredAssertion :: string -> string -> string -> attrs
  #
  # Returns an assertion that checks if `attrset.attr` is set (not falsy).
  makeRequiredAssertion = attrset: attrsetPath: attr: {
    assertion = !(isFalsy attrset.${attr});
    message = "Required attribute '${attrsetPath}.${attr}' is missing.";
  };
}
