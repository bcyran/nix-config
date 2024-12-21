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
  ttkbootstrap = pkgs.callPackage ./ttkbootstrap {
    inherit (python3Packages) buildPythonPackage pythonOlder tkinter pillow;
  };
  philipstv-gui = pkgs.callPackage ./philipstv-gui {
    inherit (python3Packages) buildPythonApplication pythonOlder poetry-core poetry-dynamic-versioning appdirs philipstv;
    inherit ttkbootstrap;
  };
  kidex = pkgs.callPackage ./kidex {};
  ente-photos-desktop = pkgs.callPackage ./ente-photos-desktop {};
  # TODO: Remove when it's merged into nixpkgs.
  #       See: https://github.com/NixOS/nixpkgs/pull/358586.
  caddy = pkgs.callPackage ./caddy {};
}
