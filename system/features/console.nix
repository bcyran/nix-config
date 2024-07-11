{pkgs, ...}: let
  terminusFont = pkgs.terminus_font;
in {
  console = {
    enable = true;
    earlySetup = true;
    packages = [terminusFont];
    font = "${terminusFont}/share/consolefonts/ter-224n.psf.gz";
    keyMap = "pl";
  };
}
