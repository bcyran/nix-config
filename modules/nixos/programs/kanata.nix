{
  config,
  lib,
  ...
}: let
  cfg = config.my.programs.kanata;
in {
  options.my.programs.kanata.enable = lib.mkEnableOption "kanata";

  config = lib.mkIf cfg.enable {
    services.kanata = {
      enable = true;
      keyboards = {
        default = {
          devices = [];
          config = ''
            (defsrc
              caps lmeta lalt)

            (defalias
              escctrl (tap-hold 150 150 esc lctl))

            (deflayer base
              @escctrl lalt lmeta)
          '';
        };
      };
    };
  };
}
