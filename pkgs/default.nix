# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{pkgs, ...}: {
  # example = pkgs.callPackage ./example { };
  backlight = pkgs.callPackage ./backlight {};
  volume = pkgs.callPackage ./volume {};
  wallpaper = pkgs.callPackage ./wallpaper {};
  scr = pkgs.callPackage ./scr {};
}
