{
  writeShellApplication,
  light,
  coreutils,
  gnugrep,
  gnused,
}:
writeShellApplication {
  name = "backlight";
  runtimeInputs = [light coreutils gnugrep gnused];
  text = builtins.readFile ./backlight.sh;
}
