{pkgs, ...}: {
  console = {
    enable = true;
    packages = with pkgs; [terminus_font];
    font = "ter-232n";
    keyMap = "pl";
  };
}
