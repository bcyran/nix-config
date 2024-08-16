{
  writeShellApplication,
  substituteAll,
  rofi,
  commonConfigPath,
  iconThemeName,
}: let
  rofiBin = "${rofi}/bin/rofi";
  config = substituteAll {
    name = "appmenu.rasi";
    src = ./files/appmenu.rasi;
    inherit commonConfigPath iconThemeName;
  };
in
  writeShellApplication {
    name = "rofi-appmenu";
    text = "${rofiBin} -no-lazy-grab -show drun -config ${config}";
  }
