{
  fetchFromGitHub,
  stdenv,
}: let
  rev = "d0ec619";
in
  stdenv.mkDerivation {
    pname = "joplin-plugins";
    version = "unstable-2025-02-17-${rev}";

    src = fetchFromGitHub {
      owner = "joplin";
      repo = "plugins";
      inherit rev;
      hash = "sha256-pX+zdD0r7UJWz/KgKSx8sf2GLYCrOPYg2yOLKXDZfdY=";
    };

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      for plugin in $(ls -1 plugins); do
        cp "plugins/$plugin/plugin.jpl" "$out/$plugin.jpl"
      done

      runHook postInstall
    '';

    meta = {
      description = "Plugins for joplin-desktop";
      homepage = "https://github.com/joplin/plugins";
    };
  }
