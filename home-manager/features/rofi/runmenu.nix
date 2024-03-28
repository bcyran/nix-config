{
  writeShellApplication,
  substituteAll,
  rofi,
  commonConfigPath,
}: let
  rofiBin = "${rofi}/bin/rofi";
  config = substituteAll {
    name = "appmenu.rasi";
    src = ./files/runmenu.rasi;
    inherit commonConfigPath;
  };
in
  writeShellApplication {
    name = "rofi-runmenu";
    runtimeInputs = [rofi];
    text = "${rofiBin} -no-lazy-grab -show run -config ${config}";
  }
