{
  lib,
  fetchFromGitHub,
  fetchYarnDeps,
  beamPackages,
  sqlite,
  yarn,
  nodejs,
  esbuild,
  tailwindcss_4,
  fixup-yarn-lock,
  apprise,
  yt-dlp,
}: let
  configuredTailwindVersion = "4.3.0";
in
  beamPackages.mixRelease rec {
    pname = "pinchflat-ngx";
    version = "2026.10.19";

    src = fetchFromGitHub {
      owner = "TheBadFella";
      repo = "pinchflat-ngx";
      rev = version;
      hash = "sha256-UERGizSpUjgABY5IucQ7eU7Iyoo7sZBnKeAbDfNWPV4=";
    };

    env = {
      EXQLITE_USE_SYSTEM = "1";
      EXQLITE_SYSTEM_CFLAGS = "-I${sqlite.dev}/include";
      EXQLITE_SYSTEM_LDFLAGS = "-L${sqlite.out}/lib -lsqlite3";
    };

    mixFodDeps = beamPackages.fetchMixDeps {
      pname = "mix-deps-${pname}";
      inherit src version;
      hash = "sha256-d6QNGBakyoeOrMZFIUkedacOY4porClARdM5swVX2fc=";
    };
    removeCookie = false;

    yarnOfflineCache = fetchYarnDeps {
      yarnLock = "${src}/assets/yarn.lock";
      sha256 = "sha256-m842N1+CcCw8mgyH+zZdIcyAr4tcCrKFwTJwmfHHOyw=";
    };

    nativeBuildInputs = [
      fixup-yarn-lock
      tailwindcss_4
      yarn
    ];
    buildInputs = [nodejs];

    postBuild = ''
      export HOME=$PWD
      fixup-yarn-lock ~/assets/yarn.lock
      yarn --cwd assets config --offline set yarn-offline-mirror $yarnOfflineCache
      yarn --cwd assets install --offline --frozen-lockfile --ignore-engines --ignore-scripts --no-progress
      patchShebangs ~/assets/node_modules

      for target in linux-x64 linux-arm64 macos-x64 macos-arm64; do
        ln -s "${tailwindcss_4}/bin/tailwindcss" "_build/tailwind-$target-${configuredTailwindVersion}"
      done

      for target in linux-x64 linux-arm64 darwin-x64 darwin-arm64; do
        ln -s "${esbuild}/bin/esbuild" "_build/esbuild-$target"
      done

      mix do deps.loadpaths --no-deps-check, tailwind default --minify + esbuild default --minify + phx.digest
    '';

    postInstall = ''
      wrapProgram $out/bin/pinchflat --prefix PATH : ${
        lib.makeBinPath [
          apprise
          yt-dlp
        ]
      }
    '';

    meta = {
      description = "Enhanced fork of Pinchflat with a Material UI, PostgreSQL, OIDC SSO and disk staging";
      homepage = "https://github.com/TheBadFella/pinchflat-ngx";
      changelog = "https://github.com/TheBadFella/pinchflat-ngx/releases/tag/${version}";
      license = lib.licenses.agpl3Only;
      maintainers = with lib.maintainers; [bcyran];
      platforms = lib.platforms.unix;
      mainProgram = "pinchflat";
    };
  }
