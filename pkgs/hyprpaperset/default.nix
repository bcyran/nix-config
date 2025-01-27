{
  writeShellApplication,
  coreutils,
  gawk,
  hyprland,
}:
writeShellApplication {
  name = "hyprpaperset";
  runtimeInputs = [coreutils hyprland gawk];
  text = builtins.readFile ./hyprpaperset.sh;
}
