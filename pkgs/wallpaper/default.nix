{
  writeShellApplication,
  coreutils,
}:
writeShellApplication {
  name = "wallpaper";
  runtimeInputs = [coreutils];
  text = builtins.readFile ./wallpaper.sh;
}
