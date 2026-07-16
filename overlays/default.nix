{inputs, ...}: {
  stable-packages = final: prev: {
    stable = import inputs.nixpkgs-stable {
      inherit (final) system;
      config.allowUnfree = true;
    };
  };
  fixes = final: prev: {
    # FIXME: Remove once https://github.com/NixOS/nixpkgs/pull/540681 is in unstable.
    calibre-web =
      (prev.calibre-web.override {
        python3Packages = prev.python3Packages.overrideScope (
          _pyfinal: pyprev: {
            pip-chill = pyprev.pip-chill.overridePythonAttrs (_old: rec {
              version = "1.0.5";
              src = final.fetchPypi {
                pname = "pip_chill";
                inherit version;
                hash = "sha256-55vFFKv+FE8u9SKQ9ZZ30nnLBbQIT6n4FLvlzA6gTBw=";
              };
              dependencies = [];
            });
          }
        );
      }).overrideAttrs
      (prev: {
        pythonRelaxDeps =
          prev.pythonRelaxDeps
          ++ [
            "requests"
            "certifi"
            "chardet"
          ];
      });

    # FIXME: Remove once upstream tests are fixed.
    btrsync = prev.btrsync.overrideAttrs (old: {
      disabledTests = (old.disabledTests or []) ++ [
        "TestBaseMatch"
        "TestUnderGlob"
      ];
    });
  };
}
