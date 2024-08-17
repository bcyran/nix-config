{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.my.programs.tlp;
in {
  options.my.programs.tlp.enable = mkEnableOption "tlp";

  config = mkIf cfg.enable {
    services.tlp = {
      enable = true;
      settings = {
        USB_BLACKLIST = 0;
      };
    };
  };
}
