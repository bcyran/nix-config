{
  pkgs,
  config,
  ...
}: let
  commonConfigPath = pkgs.substituteAll {
    name = "common.rasi";
    src = ./files/common.rasi;
    colorBg = "#${config.colorScheme.palette.guiBg}";
    colorBgDark = "#${config.colorScheme.palette.guiBgDark}";
    colorBgHighlight = "#${config.colorScheme.palette.guiBgHighlight}";
    colorFg = "#${config.colorScheme.palette.guiFg}";
    colorFgDark = "#${config.colorScheme.palette.guiFgDark}";
    colorAccentPrimary = "#${config.colorScheme.palette.guiAccentPrimary}";
    colorAccentSecondary = "#${config.colorScheme.palette.guiAccentSecondary}";
    colorWarning = "#${config.colorScheme.palette.guiWarning}";
    colorError = "#${config.colorScheme.palette.guiError}";
  };
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
