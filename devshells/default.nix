{
  inputs,
  pkgs,
  ...
}: {
  python = import ./python.nix {inherit inputs pkgs;};
}
