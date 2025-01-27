{
  writeShellApplication,
  coreutils,
  hyprpaperset,
}:
writeShellApplication {
  name = "wallpaper";
  runtimeInputs = [coreutils hyprpaperset];
  text = builtins.readFile ./wallpaper.sh;
}
