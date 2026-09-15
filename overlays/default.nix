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
      disabledTests =
        (old.disabledTests or [])
        ++ [
          "test_serverslist_returns_200"
          "test_serverslist_returns_list"
          "test_serverslist_has_servers"
          "test_serverslist_server_has_required_fields"
          "test_serverslist_server_types"
          "test_serverslist_server_protocols"
          "test_no_password_field_in_response"
          "test_no_uri_field_in_response"
          "test_no_credential_in_any_field"
          "test_repeated_calls_consistent"
          "test_repeated_calls_never_leak_credentials"
        ];
    });
  };
}
