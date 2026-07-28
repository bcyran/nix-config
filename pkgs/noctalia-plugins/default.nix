{
  lib,
  stdenv,
  fetchFromGitHub,
}: let
  rev = "ea21cb6";
in
  stdenv.mkDerivation {
    pname = "noctalia-plugins";
    version = "unstable-2026-07-22-${rev}";

    src = fetchFromGitHub {
      owner = "noctalia-dev";
      repo = "noctalia-plugins";
      inherit rev;
      hash = "sha256-M+7SLW+wI3KvDMj8dSrW/uUmpPiYhsXA2jpbbgL5imk=";
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
