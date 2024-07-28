# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{pkgs, ...}: let
  python3Packages = pkgs.python3.pkgs;
in rec {
  # example = pkgs.callPackage ./example { };
  backlight = pkgs.callPackage ./backlight {};
  volume = pkgs.callPackage ./volume {};
  wallpaper = pkgs.callPackage ./wallpaper {};
  scr = pkgs.callPackage ./scr {};
  philipstv = pkgs.callPackage ./philipstv {
    inherit (python3Packages) buildPythonPackage pythonOlder poetry-core poetry-dynamic-versioning pytestCheckHook requests-mock requests pydantic click appdirs;
  };
  ttkbootstrap = pkgs.callPackage ./ttkbootstrap {
    inherit (python3Packages) buildPythonPackage pythonOlder tkinter pillow;
  };
  philipstv-gui = pkgs.callPackage ./philipstv-gui {
    inherit (python3Packages) buildPythonApplication pythonOlder poetry-core poetry-dynamic-versioning appdirs;
    inherit philipstv ttkbootstrap;
  };
  timewall = pkgs.callPackage ./timewall {};
  git-smash = pkgs.callPackage ./git-smash {};
  git-chain = pkgs.callPackage ./git-chain {};
}
