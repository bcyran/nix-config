{
  config,
  lib,
  ...
}: let
  cfg = config.my.configurations.lanzaboote;
in {
  options.my.configurations.lanzaboote.enable = lib.mkEnableOption "lanzaboote";

  config = lib.mkIf cfg.enable {
    boot = {
      initrd.systemd.enable = true;
      loader.systemd-boot.enable = lib.mkForce false;
      bootspec.enable = true;
      lanzaboote = {
        enable = true;
        pkiBundle = "/etc/secureboot";
      };
    };
  };
}
