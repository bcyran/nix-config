# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{pkgs, ...}: let
  python3Packages = pkgs.python3.pkgs;
in {
  # example = pkgs.callPackage ./example { };
  backlight = pkgs.callPackage ./backlight {};
  volume = pkgs.callPackage ./volume {};
  wallpaper = pkgs.callPackage ./wallpaper {};
  scr = pkgs.callPackage ./scr {};
  philipstv = pkgs.callPackage ./philipstv {
    inherit (python3Packages) buildPythonPackage pythonOlder poetry-core poetry-dynamic-versioning pytestCheckHook requests-mock requests pydantic click appdirs;
  };
}
