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
  # See: https://github.com/NixOS/nixpkgs/issues/298539
  rofi-calc = pkgs.rofi-calc.override {rofi-unwrapped = pkgs.rofi-wayland-unwrapped;};
  rofi = pkgs.rofi-wayland.override {plugins = [rofi-calc];};
in {
  appmenu = pkgs.callPackage ./appmenu.nix {
    inherit commonConfigPath rofi;
    iconThemeName = config.gtk.iconTheme.name;
  };
  runmenu = pkgs.callPackage ./runmenu.nix {
    inherit commonConfigPath rofi;
  };
  powermenu = pkgs.callPackage ./powermenu.nix {
    inherit commonConfigPath rofi;
  };
  calc = pkgs.callPackage ./calc.nix {
    inherit commonConfigPath rofi;
  };
}
