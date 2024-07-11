{
  pkgs,
  lib,
  ...
}: let
  tuigreetBin = lib.getExe pkgs.greetd.tuigreet;
in {
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${tuigreetBin} --time --cmd Hyprland --asterisks --remember";
        user = "bazyli";
      };
    };
  };
}
