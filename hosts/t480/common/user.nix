{pkgs, ...}: {
  my = {
    user = rec {
      name = "bazyli";
      fullName = "Bazyli Cyran";
      email = "bazyli@cyran.dev";
      home = "/home/bazyli";
      configDir = "${home}/nixos-config";
      shell = pkgs.fish;
      uid = 1000;
      groups = ["networkmanager" "wheel"];
    };
  };
}
