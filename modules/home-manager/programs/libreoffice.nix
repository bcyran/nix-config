{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.my.programs.libreoffice;
in {
  options.my.programs.libreoffice.enable = lib.mkEnableOption "Libre Office";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      libreoffice-fresh
      hunspell
      hunspellDicts.pl_PL
      hunspellDicts.pl-pl
      hunspellDicts.en_US
      hunspellDicts.en-us
      hyphen
      hyphenDicts.en-us
      hyphenDicts.en_US
    ];
  };
}
