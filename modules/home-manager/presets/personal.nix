{
  pkgs,
  config,
  lib,
  my,
  ...
}: let
  inherit (lib) mkDefault;
  cfg = config.my.presets.personal;
in {
  options.my.presets.personal.enable = lib.mkEnableOption "personal";

  config = lib.mkIf cfg.enable {
    my = {
      programs = {
        signal.enable = mkDefault true;
        obsidian.enable = mkDefault true;
      };
    };

    home.packages = with pkgs; [
      portfolio
      gnucash
      gimp
      libreoffice-fresh
      anydesk
      calibre
      gthumb
      my.pkgs.ente-photos-desktop
      protonvpn-gui
      vlc
      tor-browser
      quickemu
      anytype
      appflowy
    ];
  };
}
