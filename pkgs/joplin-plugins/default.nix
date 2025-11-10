{
  fetchFromGitHub,
  stdenv,
}: let
  rev = "ce93e71";
in
  stdenv.mkDerivation {
    pname = "joplin-plugins";
    version = "unstable-2025-11-11-${rev}";

    src = fetchFromGitHub {
      owner = "joplin";
      repo = "plugins";
      inherit rev;
      hash = "sha256-X6SCLI9VwJIlWxZDiAYphZGwE141OPSGRPr+4aJbABE=";
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
