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
    # FIXME: nixpkgs' cargo-setup-hook now exports LIBGIT2_NO_VENDOR=1 for every
    # Rust package, forcing libgit2-sys to use a system libgit2. git-chain pulls
    # in libgit2-sys 0.17.0, which requires libgit2 >=1.8.1 <1.9.0, while
    # nixpkgs ships 1.9.x, and git-chain does not depend on libgit2 at all, so
    # the probe fails and the build aborts. Reset the variable after the setup
    # hook so libgit2-sys vendors its bundled libgit2. Remove when nixpkgs fixes
    # git-chain (e.g. by updating git2 or adding a compatible libgit2).
    git-chain = prev.git-chain.overrideAttrs (old: {
      preBuild = (old.preBuild or "") + "\nexport LIBGIT2_NO_VENDOR=0\n";
    });

    # FIXME: nixpkgs now devendors Rust dependencies, so libsodium-sys probes
    # the system libsodium via pkg-config instead of building the bundled one,
    # but the package does not list libsodium in buildInputs. Remove when
    # https://github.com/NixOS/nixpkgs/issues/585458 is fixed.
    rustdesk-flutter = prev.rustdesk-flutter.overrideAttrs (old: {
      buildInputs = (old.buildInputs or []) ++ [prev.libsodium];
    });

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

    # FIXME: mini-graph-card < 0.14.0-dev.3 stacks color_thresholds stops
    # outside the Y-axis on the top edge, painting a bogus band of the hottest
    # color above the line. dev.3 fixes the stacking (#1361, #1441) but leaves
    # the first stop at the graph edge, so the line stroke still picks up the
    # out-of-range color; the patch pins the gradient to the graph bounds.
    # Remove the pin and the patch when nixpkgs ships a release with this fix.
    home-assistant-custom-lovelace-modules = prev.lib.recurseIntoAttrs (
      prev.home-assistant-custom-lovelace-modules.extend (_hfinal: hprev: {
        mini-graph-card = hprev.mini-graph-card.overrideAttrs (_old: {
          version = "0.14.0-dev.3-p1";
          src = prev.fetchFromGitHub {
            owner = "kalkih";
            repo = "mini-graph-card";
            tag = "v0.14.0-dev.3";
            hash = "sha256-1ZSnFkVJ7m6c4rLBJG+hNpfRWo5Jr9SP6GuQOBAoVc8=";
          };
          npmDepsHash = "sha256-xzhyYYZLl8pyfK3+MRn35Ffdw/c78v8PjwLlAuQO92g=";
          patches = [./mini-graph-card-gradient.patch];
        });
      })
    );

    pythonPackagesExtensions =
      prev.pythonPackagesExtensions
      ++ [
        (pyfinal: pyprev: {
          # FIXME: nixpkgs now devendors Rust dependencies, so zstd-sys and
          # aws-lc-sys probe the system libzstd and aws-lc via pkg-config, but
          # primp (a dependency of open-webui through ddgs) lists none of them.
          # Remove when fixed upstream.
          primp = pyprev.primp.overrideAttrs (old: {
            nativeBuildInputs = (old.nativeBuildInputs or []) ++ [prev.pkg-config];
            buildInputs = (old.buildInputs or []) ++ [prev.zstd prev.aws-lc];
          });

          # FIXME: same as primp: libsqlite3-sys and tikv-jemalloc-sys now probe
          # system libraries, but chromadb (a dependency of open-webui) does not
          # list sqlite or rust-jemalloc-sys in buildInputs. Remove when fixed
          # upstream.
          chromadb = pyprev.chromadb.overrideAttrs (old: {
            buildInputs = (old.buildInputs or []) ++ [prev.sqlite prev.rust-jemalloc-sys];
          });

          # FIXME: nixpkgs bumped python3Packages.mcp to 2.x
          # (https://github.com/NixOS/nixpkgs/pull/575004), which fastmcp-slim
          # does not support, so it is marked broken and breaks mcp-nixos.
          # Build it against mcp_1 instead. Remove when fixed upstream.
          fastmcp-slim = pyprev.fastmcp-slim.override {mcp = pyfinal.mcp_1;};
        })
      ];
  };
}
