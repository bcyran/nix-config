{lib}: {
  # dir :: listOf paths
  #
  # Returns a list of absolute string paths to all entries in a directory.
  listDir = dir:
    map
    (name: "${dir}/${name}")
    (builtins.attrNames
      (builtins.readDir dir));
}
