{
  fetchFromGitHub,
  stdenv,
}: let
  rev = "eea097f";
in
  stdenv.mkDerivation {
    pname = "joplin-plugins";
    version = "unstable-2026-07-28-${rev}";

    src = fetchFromGitHub {
      owner = "joplin";
      repo = "plugins";
      inherit rev;
      hash = "sha256-piBC+HRda/ISAC9xZQUXS0o+0DX8MA88ZXE8apad9nE=";
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
