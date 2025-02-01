{
  lib,
  buildGoModule,
  fetchFromGitHub,
  mage,
  writeShellScriptBin,
  pkg-config,
  libGL,
  libX11,
  libXcursor,
  libXrandr,
  libXinerama,
  libXi,
  libXxf86vm,
}: let
  version = "v11.1.2";
  # Result of `git describe --tags --always --dirty`
  commitHashShort = "101b2a8a";
  # Result of `git log --date=iso8601-strict -1 --pretty=%ct`
  commitTimestamp = "1738389749";

  fakeGit = writeShellScriptBin "git" ''
    if [[ $@ = "describe --tags --always --dirty" ]]; then
        echo "${version}"
    elif [[ $@ = "rev-parse --short HEAD" ]]; then
        echo "${commitHashShort}"
    elif [[ $@ = "log --date=iso8601-strict -1 --pretty=%ct" ]]; then
        echo "${commitTimestamp}"
    else
        >&2 echo "Unknown command: $@"
        exit 1
    fi
  '';
in
  buildGoModule rec {
    pname = "go-hass-agent";
    inherit version;

    src = fetchFromGitHub {
      owner = "joshuar";
      repo = "go-hass-agent";
      rev = "refs/tags/${version}";
      hash = "sha256-c2TldMY05Au4gwYiIDPi/gQuOHVnT+/0ycgGHKErZyA=";
    };

    vendorHash = "sha256-02sWRWWadZFMaLjJV181bAioNyuN7mG0ZzrkrTdUTqU=";

    nativeBuildInputs = [
      pkg-config
      mage
      fakeGit
    ];

    buildInputs = [
      libGL
      libX11
      libXcursor
      libXrandr
      libXinerama
      libXi
      libXxf86vm
    ];

    buildPhase = ''
      runHook preBuild

      # Fixes "mkdir /homeless-shelter: permission denied" - "Error: error compiling magefiles" during build
      export HOME=$(mktemp -d)
      mage -d build/magefiles -w . build:full

      runHook postBuild
    '';

    ldflags = ["-s" "-w"];

    checkPhase = ''
      mage -d build/magefiles -w . tests:test
    '';

    installPhase = ''
      runHook preInstall

      # Output binary name contains arch name, e.g. go-hass-agent-amd64
      install -D "$(ls -1 dist/go-hass-agent-*)" $out/bin/go-hass-agent

      runHook postInstall
    '';

    meta = {
      description = "A Home Assistant, native app for desktop/laptop devices";
      homepage = "https://github.com/joshuar/go-hass-agent";
      changelog = "https://github.com/joshuar/go-hass-agent/blob/${src.rev}/CHANGELOG.md";
      license = lib.licenses.mit;
      mainProgram = "go-hass-agent";
      platforms = lib.platforms.linux;
    };
  }
