{
  fetchFromGitHub,
  stdenv,
}: let
  rev = "5b95e18";
in
  stdenv.mkDerivation {
    pname = "joplin-plugins";
    version = "unstable-2026-06-05-${rev}";

    src = fetchFromGitHub {
      owner = "joplin";
      repo = "plugins";
      inherit rev;
      hash = "sha256-i24UvWb5G1L7P4EWK93UG9o9QIjTMuQm6l/hzOrTWNI=";
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
