{pkgs, ...}: {
  users = {
    users = {
      bazyli = {
        isNormalUser = true;
        description = "Bazyli Cyran";
        extraGroups = ["networkmanager" "wheel" "video"];
        shell = pkgs.fish;
        uid = 1000;
      };
    };
    groups = {
      video = {};
    };
  };
}
