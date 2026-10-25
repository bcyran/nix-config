{inputs, ...}: {
  stable-packages = final: prev: {
    stable = import inputs.nixpkgs-stable {
      inherit (final) system;
      config.allowUnfree = true;
    };
  };
  fixes = final: prev: let
    # FIXME: speech-dispatcher needs python at build time to build its Python
    # library; with strictDeps it must be in nativeBuildInputs, otherwise Orca
    # produces no sound. Backport of
    # https://github.com/NixOS/nixpkgs/pull/577607. Remove when that PR
    # reaches nixos-unstable.
    patchedSpeechd = prev.speechd.overrideAttrs (old: {
      nativeBuildInputs =
        (old.nativeBuildInputs or [])
        ++ [prev.python3Packages.python];
      buildInputs = prev.lib.lists.remove prev.python3Packages.python (
        old.buildInputs or []
      );
    });
    patchedSpeechdMinimal = patchedSpeechd.override {
      withLibao = false;
      withPulse = false;
      withAlsa = false;
      withOss = false;
      withFlite = false;
      withEspeak = false;
      withPico = false;
      withPipewire = false;
    };
  in {
    glances = prev.glances.overrideAttrs (old: {
      # These modules spawn the Glances server with subprocess.Popen, wait a
      # fixed time.sleep(5) instead of polling, then immediately make HTTP
      # requests. Under the load of a parallel nixos-rebuild the server
      # often is not available yet, so the requests fail with ConnectionError.
      disabledTestPaths =
        (old.disabledTestPaths or [])
        ++ [
          "tests/test_restful.py"
          "tests/test_xmlrpc.py"
          "tests/test_browser_restful.py"
        ];
    });

    # Only patch the packages that actually consume speechd's Python bindings
    # (qtspeech only needs the C library, so it doesn't need this) to avoid
    # rebuilding chromium and everything else that links speechd/speechd-minimal.
    calibre = prev.calibre.override {
      speechSupport = true;
      speechd-minimal = patchedSpeechdMinimal;
    };

    pythonPackagesExtensions =
      prev.pythonPackagesExtensions
      ++ [
        (pyfinal: pyprev: {
          # FIXME: nixpkgs bumped python3Packages.mcp to 2.x
          # (https://github.com/NixOS/nixpkgs/pull/575004), which fastmcp-slim
          # does not support, so it is marked broken and breaks mcp-nixos.
          # Build it against mcp_1 instead. Remove when fixed upstream.
          fastmcp-slim = pyprev.fastmcp-slim.override {mcp = pyfinal.mcp_1;};
        })
      ];

    # FIXME: Remove when https://github.com/containers/podman/issues/29805 is fixed.
    # Podman 5.8.7 fails to copy archives into containers when the target path
    # crosses an absolute symlink such as /var/run -> /run ("path escapes from
    # parent"), which breaks Forgejo runner jobs. Pin to the last good version.
    # https://github.com/containers/podman/issues/29805
    podman = prev.podman.overrideAttrs (old: let
      version = "5.8.4";
    in {
      inherit version;
      src = prev.fetchFromGitHub {
        owner = "podman-container-tools";
        repo = "podman";
        tag = "v${version}";
        hash = "sha256-zhEtMZVKiv1L72EMlwgz8sHpmvhejGp98oW63aPj+rQ=";
      };
      doInstallCheck = false;
    });
  };
}
