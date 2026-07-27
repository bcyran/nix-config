{inputs, ...}: {
  stable-packages = final: prev: {
    stable = import inputs.nixpkgs-stable {
      inherit (final) system;
      config.allowUnfree = true;
    };
  };
  fixes = final: prev: {
    # FIXME: Remove once upstream tests are fixed.
    btrsync = prev.btrsync.overrideAttrs (old: {
      disabledTests = (old.disabledTests or []) ++ [
        "TestBaseMatch"
        "TestUnderGlob"
      ];
    });
    glances = prev.glances.overrideAttrs (old: {
      disabledTests = (old.disabledTests or []) ++ [
        "test_serverslist_returns_200"
        "test_serverslist_returns_list"
        "test_serverslist_has_servers"
        "test_serverslist_server_has_required_fields"
        "test_serverslist_server_types"
      ];
    });
  };
}
