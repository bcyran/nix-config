{
  lib,
  buildGoModule,
  fetchFromGitHub,
  buildNpmPackage,
}: let
  version = "v14.1.0";

  src = fetchFromGitHub {
    owner = "joshuar";
    repo = "go-hass-agent";
    rev = "refs/tags/${version}";
    hash = "sha256-g+7+a6Wtgqdj8n1D/vPtQLRRVDP155SVSotAsONde/4=";
  };

  frontend = buildNpmPackage {
    pname = "go-hass-agent-frontend";
    inherit version src;

    npmDepsHash = "sha256-m+5xVkYmf/0K5Bi4IQEBd82r9yxlNW5TsNbqdu2Lqjw=";

    postPatch = ''
      cp ${./package-lock.json} package-lock.json
    '';

    buildPhase = ''
      runHook preBuild

      npx esbuild ./web/assets/scripts.js --bundle --minify --outdir=./web/content/
      npx tailwindcss -i ./web/assets/styles.css -o ./web/content/styles.css --minify

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -r web/content/* $out/

      runHook postInstall
    '';
  };
in
  buildGoModule rec {
    pname = "go-hass-agent";
    inherit version src;

    vendorHash = "sha256-RMTgvFUgE8u++D9wdBhytpj/NxNAWVVcLjSPi3n5hD8=";

    preBuild = ''
      cp -r ${frontend}/* web/content/
    '';

    ldflags = [
      "-s"
      "-w"
      "-X github.com/joshuar/go-hass-agent/config.AppVersion=${version}"
    ];

    meta = {
      description = "A Home Assistant, native app for desktop/laptop devices";
      homepage = "https://github.com/joshuar/go-hass-agent";
      changelog = "https://github.com/joshuar/go-hass-agent/blob/${src.rev}/CHANGELOG.md";
      license = lib.licenses.mit;
      mainProgram = "go-hass-agent";
      platforms = lib.platforms.linux;
    };
  }
