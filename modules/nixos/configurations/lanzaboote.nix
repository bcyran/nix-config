{
  config,
  lib,
  ...
}: let
  cfg = config.my.configurations.lanzaboote;
in {
  options.my.configurations.lanzaboote = {
    enable = lib.mkEnableOption "lanzaboote";

    pkiBundle = lib.mkOption {
      type = lib.types.path;
      description = "Path to the lanzaboote PKI bundle directory.";
      default = "/var/lib/sbctl";
    };
  };

  config = lib.mkIf cfg.enable {
    boot = {
      initrd.systemd.enable = true;
      loader.systemd-boot.enable = lib.mkForce false;
      bootspec.enable = true;
      lanzaboote = {
        enable = true;
        inherit (cfg) pkiBundle;
      };
    };
  };
}
