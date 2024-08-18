{lib}: rec {
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

  # mmkMy :: attrs -> string -> attrs
  #
  # Returns a new `my` attrset with system specific `pkgs` from `my.packages.{system}`.
  mkMyForSystem = my: system:
    my
    // {
      pkgs = my.packages.${system};
    };
}
