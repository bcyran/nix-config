{
  writeShellApplication,
  coreutils,
  swww,
}:
writeShellApplication {
  name = "wallpaper";
  runtimeInputs = [coreutils swww];
  text = builtins.readFile ./wallpaper.sh;
}
