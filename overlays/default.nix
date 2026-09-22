{inputs, ...}: {
  stable-packages = final: prev: {
    stable = import inputs.nixpkgs-stable {
      inherit (final) system;
      config.allowUnfree = true;
    };
  };
  fixes = final: prev: let
    bun_1_3_13 = prev.bun.overrideAttrs (old: rec {
      version = "1.3.13";
      src = prev.fetchurl {
        url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-linux-x64-baseline.zip";
        hash = "sha256-nYokKSpwaAkCBdqsCloiP19pc29Sh+N7+I07QDHtx1A=";
      };
    });
  in {
    # FIXME: Remove once https://github.com/NixOS/nixpkgs/issues/563241 is fixed
    opencode = prev.opencode.override {bun = bun_1_3_13;};

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
  };
}
