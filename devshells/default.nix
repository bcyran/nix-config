{
  inputs,
  pkgs,
  ...
}: {
  default = pkgs.mkShell {
    packages = [pkgs.just];
  };
  python = import ./python.nix {inherit inputs pkgs;};
}
