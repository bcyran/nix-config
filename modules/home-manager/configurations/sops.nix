{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.my.configurations.sops;
in {
  options.my.configurations.sops.enable = lib.mkEnableOption "sops";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      sops
      age
      ssh-to-age
    ];

    sops.age.sshKeyPaths = ["${config.my.user.home}/.ssh/id_ed25519"];
  };
}
