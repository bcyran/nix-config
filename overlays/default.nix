{inputs, ...}: {
  stable-packages = final: prev: {
    stable = import inputs.nixpkgs-stable {
      inherit (final) system;
      config.allowUnfree = true;
    };
  };
  fixes = final: prev: {
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
