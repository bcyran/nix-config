{
  lib,
  stdenv,
  fetchFromGitHub,
}: let
  rev = "cb10d23";
in
  stdenv.mkDerivation {
    pname = "noctalia-plugins";
    version = "unstable-2026-05-07-${rev}";

    src = fetchFromGitHub {
      owner = "noctalia-dev";
      repo = "noctalia-plugins";
      inherit rev;
      hash = "sha256-vgJj89YeiU2FQ+cXIraPx/XdiAMC9Cj+rJqC//O4Na4=";
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
