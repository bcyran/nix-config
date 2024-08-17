{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.my.configurations.lanzaboote;
in {
  options.my.configurations.lanzaboote.enable = mkEnableOption "lanzaboote";

  config = mkIf cfg.enable {
    boot = {
      initrd.systemd.enable = true;
      loader.systemd-boot.enable = mkForce false;
      bootspec.enable = true;
      lanzaboote = {
        enable = true;
        pkiBundle = "/etc/secureboot";
      };
    };
  };
}
