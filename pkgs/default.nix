# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{pkgs, ...}: let
  python3Packages = pkgs.python3.pkgs;
  inherit (pkgs) python314Packages;
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
  philipstv = pkgs.callPackage ./philipstv {
    inherit (pkgs) installShellFiles;
    inherit (python3Packages) buildPythonPackage pythonOlder hatchling hatch-vcs pytestCheckHook requests-mock requests pydantic click appdirs;
  };
  philipstv-gui = pkgs.callPackage ./philipstv-gui {
    inherit (python3Packages) buildPythonApplication pythonOlder hatchling hatch-vcs appdirs;
    inherit ttkbootstrap philipstv;
  };
  joplin-plugins = pkgs.callPackage ./joplin-plugins {};
  xiaomi_miio_fan = pkgs.callPackage ./xiaomi_miio_fan {
    inherit (python314Packages) python-miio;
  };
  koinsight = pkgs.callPackage ./koinsight {};
  fio-bench = pkgs.callPackage ./fio-bench {
    inherit (pkgs) writeShellApplication fio jq;
  };
  btrsync = pkgs.callPackage ./btrsync {
    inherit (python3Packages) buildPythonPackage setuptools pytestCheckHook;
  };
  bentopdf = pkgs.callPackage ./bentopdf {};
  livecodes = pkgs.callPackage ./livecodes {};
  jellystat = pkgs.callPackage ./jellystat {};
  noctalia-plugins = pkgs.callPackage ./noctalia-plugins {};
  openchamber = pkgs.callPackage ./openchamber {};
}
