{
  lib,
  toIntBase16,
}: {
  # hexToRGBString :: string -> string -> string
  #
  # Converts a hex color string (e.g. "ff757f" or "#ff757f") to an RGB string
  # separated by the given separator (e.g. "," → "255,117,127").
  hexToRGBString = sep: hex: let
    h = lib.removePrefix "#" hex;
  in
    builtins.concatStringsSep sep (map (x: toString (toIntBase16 x)) [
      (builtins.substring 0 2 h)
      (builtins.substring 2 2 h)
      (builtins.substring 4 2 h)
    ]);
}
