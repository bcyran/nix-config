# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{pkgs, ...}: let
  inherit (pkgs) python314Packages;
in rec {
  # example = pkgs.callPackage ./example { };
  joplin-plugins = pkgs.callPackage ./joplin-plugins {};
  xiaomi_miio_fan = pkgs.callPackage ./xiaomi_miio_fan {
    inherit (python314Packages) python-miio;
  };
  koinsight = pkgs.callPackage ./koinsight {};
  fio-bench = pkgs.callPackage ./fio-bench {
    inherit (pkgs) writeShellApplication fio jq;
  };
  bentopdf = pkgs.callPackage ./bentopdf {};
  livecodes = pkgs.callPackage ./livecodes {};
  jellystat = pkgs.callPackage ./jellystat {};
  pinchflat-ngx = pkgs.callPackage ./pinchflat-ngx {};
  wyoming-openai-gateway = pkgs.callPackage ./wyoming-openai-gateway {};
}
