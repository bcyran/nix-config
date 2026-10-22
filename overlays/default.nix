{inputs, ...}: {
  stable-packages = final: prev: {
    stable = import inputs.nixpkgs-stable {
      inherit (final) system;
      config.allowUnfree = true;
    };
  };
  fixes = final: prev: {
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

    pythonPackagesExtensions =
      prev.pythonPackagesExtensions
      ++ [
        (pyfinal: pyprev: {
          # FIXME: requests-hardened 1.3.0 pins uv_build<0.12.0 in pyproject.toml, but
          # nixpkgs already ships uv-build 0.12.x, which makes pypaBuildPhase fail
          # the build dependency check. Relax the upper bound until upstream
          # releases a version compatible with the newer uv_build.
          requests-hardened = pyprev.requests-hardened.overrideAttrs (old: {
            postPatch =
              (old.postPatch or "")
              + ''
                substituteInPlace pyproject.toml \
                  --replace-fail 'uv_build>=0.11.0,<0.12.0' 'uv_build>=0.11.0,<0.13.0'
              '';
          });

          # FIXME: pyopenjtalk-plus's test suite expects its own "must be str"
          # TypeError, but Cython 3.3.0 now type-checks list[str] elements first
          # and raises its own message. This breaks piper-tts and, through it,
          # calibre. Backport of the upstream test fix
          # (tsukumijima/pyopenjtalk-plus@90b644f) via fetchpatch, the same patch
          # https://github.com/NixOS/nixpkgs/pull/576063 adds. Remove when that PR
          # reaches nixos-unstable.
          pyopenjtalk-plus = pyprev.pyopenjtalk-plus.overrideAttrs (old: {
            patches =
              (old.patches or [])
              ++ [
                (final.fetchpatch {
                  name = "fix-cython-3.3.0.patch";
                  url = "https://github.com/tsukumijima/pyopenjtalk-plus/commit/90b644f9e9d397882e6eafe4dcd1843a4fde6a63.patch";
                  includes = ["tests/test_frontend.py"];
                  hash = "sha256-Jb7T/bRUHxqwBLwV6xYC/teaFHm5GmqJxA7sCX+oiNI=";
                })
              ];
          });
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
