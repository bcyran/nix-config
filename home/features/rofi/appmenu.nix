{
  writeShellApplication,
  substituteAll,
  rofi,
  commonConfigPath,
}: let
  rofiBin = "${rofi}/bin/rofi";
  config = substituteAll {
    name = "appmenu.rasi";
    src = ./files/appmenu.rasi;
    inherit commonConfigPath;
  };
in
  writeShellApplication {
    name = "rofi-appmenu";
    runtimeInputs = [rofi];
    text = "${rofiBin} -no-lazy-grab -show drun -config ${config}";
  }
