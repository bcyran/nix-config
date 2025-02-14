# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{pkgs, ...}: let
  python3Packages = pkgs.python3.pkgs;

  mkHyprlandPlugin = hyprland: args @ {pluginName, ...}:
    hyprland.stdenv.mkDerivation (
      args
      // {
        pname = "${pluginName}";
        nativeBuildInputs = [pkgs.pkg-config] ++ args.nativeBuildInputs or [];
        buildInputs = [hyprland] ++ hyprland.buildInputs ++ (args.buildInputs or []);
        meta =
          args.meta
          // {
            description = args.meta.description or "";
            longDescription =
              (args.meta.longDescription or "")
              + "\n\nPlugins can be installed via a plugin entry in the Hyprland NixOS or Home Manager options.";
          };
      }
    );
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
  go-hass-agent = pkgs.callPackage ./go-hass-agent {};
  hy3 = pkgs.callPackage ./hy3 {inherit mkHyprlandPlugin;};
}
