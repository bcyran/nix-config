{
  config,
  lib,
  ...
}: let
  cfg = config.my.programs.tlp;
in {
  options.my.programs.tlp.enable = lib.mkEnableOption "tlp";

  config = lib.mkIf cfg.enable {
    services.tlp = {
      enable = true;
      settings = {
        USB_BLACKLIST = 0;
      };
    };
  };
}
