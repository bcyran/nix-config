{inputs, ...}: {
  stable-packages = final: prev: {
    stable = import inputs.nixpkgs-stable {
      inherit (final) system;
      config.allowUnfree = true;
    };
  };
  # TODO: Remove once fish 4.x is fixed and stable
  fish-stable = final: prev: {
    inherit (prev.stable) fish;
  };
}
