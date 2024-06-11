{
  pkgs,
  config,
  ...
}: let
  commonConfigPath = pkgs.substituteAll ({
      name = "common.rasi";
      src = ./files/common.rasi;
    }
    // config.colorScheme.palette);
  rofi = pkgs.rofi-wayland.override {plugins = [pkgs.rofi-calc];};
in {
  appmenu = pkgs.callPackage ./appmenu.nix {
    inherit commonConfigPath rofi;
  };
  runmenu = pkgs.callPackage ./runmenu.nix {
    inherit commonConfigPath rofi;
  };
  powermenu = pkgs.callPackage ./powermenu.nix {
    inherit commonConfigPath rofi;
    lockerBin = "${config.programs.swaylock.package}/bin/swaylock";
  };
  calc = pkgs.callPackage ./calc.nix {
    inherit commonConfigPath rofi;
  };
}
