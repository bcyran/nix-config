{
  fetchFromGitHub,
  stdenv,
}: let
  rev = "769b458";
in
  stdenv.mkDerivation {
    pname = "joplin-plugins";
    version = "unstable-2025-09-06-${rev}";

    src = fetchFromGitHub {
      owner = "joplin";
      repo = "plugins";
      inherit rev;
      hash = "sha256-g4lsMurp7qlvzBL4oWZTkPp+iyktw5NBMO2EKbKphIA=";
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
