{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.my.configurations.console;

  terminusFont = pkgs.terminus_font;
in {
  options.my.configurations.console.enable = mkEnableOption "console";

  config = mkIf cfg.enable {
    console = {
      enable = true;
      earlySetup = true;
      packages = [terminusFont];
      font = "${terminusFont}/share/consolefonts/ter-224n.psf.gz";
      keyMap = "pl";
    };
  };
}
