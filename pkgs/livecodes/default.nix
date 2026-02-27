{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  writeShellScriptBin,
  python3,
}: let
  # The build script calls `git rev-parse --short=7 HEAD` to embed a commit hash.
  fake-git = writeShellScriptBin "git" ''
    if [ "$1" = "rev-parse" ]; then
      hash=$(cat .gitrev 2>/dev/null || echo "0000000")
      case "$2" in
        --short=*) len=''${2#--short=}; printf '%s\n' "$(printf '%s' "$hash" | cut -c1-"$len")" ;;
        --short)   printf '%s\n' "$(printf '%s' "$hash" | cut -c1-7)" ;;
        *)         printf '%s\n' "$hash" ;;
      esac
    else
      echo "fake-git: unsupported command: $@" >&2
      exit 1
    fi
  '';
in
  buildNpmPackage rec {
    pname = "livecodes";
    version = "48";

    src = fetchFromGitHub {
      owner = "live-codes";
      repo = "livecodes";
      tag = "v${version}";
      leaveDotGit = true;
      hash = "sha256-QikmlJfyoFXnMLA9xZ9wEMgo5I+LqAwdcvX2tVhWs5w=";
      postFetch = ''
        pushd $out
        git rev-parse HEAD > .gitrev
        rm -rf .git
        popd
      '';
    };

    npmDepsHash = "sha256-t1VcRVOlyCYs8ofe/RNQOsW0yCwwOxsiKyGzEt4p9jE=";

    nativeBuildInputs = [fake-git];

    makeCacheWritable = true;

    # The postinstall script runs patch-package and tries to npm ci in
    # docs/, storybook/, and server/ subdirectories. We only need the main
    # app build, so strip the sub-project installs to avoid network access
    # and missing lockfile issues in the sandbox.
    postPatch = let
      patchPostinstall = ''
        import json

        with open("package.json", "r") as f:
            pkg = json.load(f)

        scripts = pkg.get("scripts", {})
        # Keep patch-package but remove sub-project installs
        scripts["postinstall"] = "patch-package"
        # Remove prebuild/postbuild i18n-exclude hooks that modify source
        # files (they work fine but are unnecessary for the app-only build)
        scripts.pop("prebuild", None)
        scripts.pop("postbuild", None)

        with open("package.json", "w") as f:
            json.dump(pkg, f, indent=2)
      '';
    in ''
      ${python3}/bin/python3 -c ${lib.escapeShellArg patchPostinstall}
    '';

    npmBuildScript = "build:app";

    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/livecodes
      cp -r build/* $out/share/livecodes/
      runHook postInstall
    '';

    meta = {
      description = "A feature-rich, open-source, client-side code playground";
      homepage = "https://livecodes.io";
      changelog = "https://github.com/live-codes/livecodes/blob/v${version}/CHANGELOG.md";
      license = lib.licenses.mit;
    };
  }
