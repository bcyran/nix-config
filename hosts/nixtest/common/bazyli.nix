{pkgs, ...}: {
  my = {
    user = rec {
      name = "bazyli";
      fullName = "Bazyli Cyran";
      email = "bazyli@cyran.dev";
      home = "/home/bazyli";
      dotfilesDir = "${home}/dotfiles-nix";
      shell = pkgs.fish;
      uid = 1000;
      groups = ["networkmanager" "wheel"];
    };
  };
}
