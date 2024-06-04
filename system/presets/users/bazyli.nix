{pkgs, ...}: {
  users = {
    users = {
      bazyli = {
        isNormalUser = true;
        description = "Bazyli Cyran";
        extraGroups = ["networkmanager" "wheel" "video"];
        shell = pkgs.fish;
      };
    };
    groups = {
      video = {};
    };
  };
}
