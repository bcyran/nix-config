{
  lib,
  stdenv,
  fetchFromGitHub,
}: let
  pname = "icomoon-feather";
  version = "1.0";
  revision = "4b0e9a95d48cc3e9b85934d33fcb776eae4a7bd7";
in
  stdenv.mkDerivation {
    name = "${pname}-${version}";

    src = fetchFromGitHub {
      owner = "adi1090x";
      repo = "polybar-themes";
      rev = "${revision}";
      sha256 = "0lp1sqxzbc0w9df5jm0h7bkcdf94ahf4929vmf14y7yhbfy2llf3";
    };

    installPhase = ''
      install -Dm 445 $src/fonts/feather.ttf -t $out/share/fonts/truetype
    '';

    meta = with lib; {
      description = "Icomoon Feather";
      longDescription = "Icomoon Feather icon font";
      homepage = "https://github.com/adi1090x/polybar-themes";
      license = licenses.gpl3Only;
      platforms = platforms.all;
    };
  }
