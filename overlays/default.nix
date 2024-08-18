_: {
  # This one brings our custom packages from the 'pkgs' directory.
  # They will be accessible through `pkgs.my.packagename`.
  additions = final: _prev: {
    my = import ../pkgs {pkgs = final;};
  };

  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });
  };
}
