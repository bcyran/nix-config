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

    # FIXME: requests-hardened 1.3.0 pins uv_build<0.12.0 in pyproject.toml, but
    # nixpkgs already ships uv-build 0.12.x, which makes pypaBuildPhase fail
    # the build dependency check. Relax the upper bound until upstream
    # releases a version compatible with the newer uv_build.
    pythonPackagesExtensions =
      prev.pythonPackagesExtensions
      ++ [
        (pyfinal: pyprev: {
          requests-hardened = pyprev.requests-hardened.overrideAttrs (old: {
            postPatch =
              (old.postPatch or "")
              + ''
                substituteInPlace pyproject.toml \
                  --replace-fail 'uv_build>=0.11.0,<0.12.0' 'uv_build>=0.11.0,<0.13.0'
              '';
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
