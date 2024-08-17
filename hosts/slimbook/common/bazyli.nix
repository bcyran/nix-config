{pkgs, ...}: {
  my = {
    user = {
      name = "bazyli";
      fullName = "Bazyli Cyran";
      email = "bazyli@cyran.dev";
      home = "/home/bazyli";
      shell = pkgs.fish;
      uid = 1000;
      groups = ["networkmanager" "wheel" "video"];
    };
  };
}
