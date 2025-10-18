# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{pkgs, ...}: let
  python3Packages = pkgs.python3.pkgs;
  inherit (pkgs) python313Packages;
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
    inherit (python3Packages) buildPythonPackage pythonOlder tkinter pillow setuptools;
  };
  philipstv-gui = pkgs.callPackage ./philipstv-gui {
    inherit (python3Packages) buildPythonApplication pythonOlder poetry-core poetry-dynamic-versioning appdirs philipstv;
    inherit ttkbootstrap;
  };
  kidex = pkgs.callPackage ./kidex {};
  go-hass-agent = pkgs.callPackage ./go-hass-agent {};
  joplin-plugins = pkgs.callPackage ./joplin-plugins {};
  xiaomi_miio_fan = pkgs.callPackage ./xiaomi_miio_fan {
    inherit (python313Packages) python-miio;
  };
  koinsight = pkgs.callPackage ./koinsight {};
  flint-kvm = pkgs.callPackage ./flint-kvm {};
}
