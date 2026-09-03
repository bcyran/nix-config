{
  my,
  lib,
  ...
}: let
  inherit (lib) mkOption types;
in {
  options.my.colorscheme = {
    slug = mkOption {
      type = types.str;
      description = "Short identifier for the colorscheme";
    };
    name = mkOption {
      type = types.str;
      description = "Human-readable name of the colorscheme";
    };
    author = mkOption {
      type = types.str;
      description = "Author of the colorscheme";
    };
    palette = mkOption {
      type = types.attrsOf types.str;
      description = "Color palette as attribute set of hex color strings (without #)";
    };
  };
}
