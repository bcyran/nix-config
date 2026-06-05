{
  lib,
  stdenv,
  fetchFromGitHub,
}: let
  rev = "2218cf8";
in
  stdenv.mkDerivation {
    pname = "noctalia-plugins";
    version = "unstable-2026-06-03-${rev}";

    src = fetchFromGitHub {
      owner = "noctalia-dev";
      repo = "noctalia-plugins";
      inherit rev;
      hash = "sha256-jOHmyhHBEk4CjiroB6Ju+5mml1uQtGfMjcuu1fhCSfs=";
    };

    dontBuild = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      for dir in */; do
        if [[ -f "$dir/manifest.json" ]]; then
          cp -r "$dir" "$out/"
        fi
      done

      runHook postInstall
    '';

    meta = {
      description = "Official plugin registry for Noctalia Shell";
      homepage = "https://github.com/noctalia-dev/noctalia-plugins";
      license = lib.licenses.mit;
      platforms = lib.platforms.linux;
    };
  }
