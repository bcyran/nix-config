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
}
