{
  writeShellApplication,
  substituteAll,
  rofi,
  commonConfigPath,
}: let
  rofiBin = "${rofi}/bin/rofi";
  config = substituteAll {
    name = "calc.rasi";
    src = ./files/calc.rasi;
    inherit commonConfigPath;
  };
in
  writeShellApplication {
    name = "rofi-calc";
    text = "${rofiBin} -no-lazy-grab -show calc -config ${config}";
  }
