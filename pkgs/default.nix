# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{pkgs, ...}: let
  python3Packages = pkgs.python3.pkgs;
in rec {
  # example = pkgs.callPackage ./example { };
  backlight = pkgs.callPackage ./backlight {};
  volume = pkgs.callPackage ./volume {};
  hyprpaperset = pkgs.callPackage ./hyprpaperset {};
  wallpaper = pkgs.callPackage ./wallpaper {
    inherit (pkgs) writeShellApplication coreutils;
    inherit hyprpaperset;
  };
  scr = pkgs.callPackage ./scr {};
  ttkbootstrap = pkgs.callPackage ./ttkbootstrap {
    inherit (python3Packages) buildPythonPackage pythonOlder tkinter pillow;
  };
  philipstv-gui = pkgs.callPackage ./philipstv-gui {
    inherit (python3Packages) buildPythonApplication pythonOlder poetry-core poetry-dynamic-versioning appdirs philipstv;
    inherit ttkbootstrap;
  };
  kidex = pkgs.callPackage ./kidex {};
}
