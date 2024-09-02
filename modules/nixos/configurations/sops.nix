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
    environment.systemPackages = with pkgs; [
      sops
      age
      ssh-to-age
    ];

    sops = {
      age = {
        sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
        keyFile = "/var/lib/sops-nix/key.txt";
        generateKey = true;
      };
    };
  };
}
