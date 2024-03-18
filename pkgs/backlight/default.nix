{
  writeShellApplication,
  light,
}:
writeShellApplication {
  name = "backlight";
  runtimeInputs = [light];
  text = builtins.readFile ./backlight.sh;
}
