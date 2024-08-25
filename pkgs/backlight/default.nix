{
  writeShellApplication,
  coreutils,
  brillo,
}:
writeShellApplication {
  name = "backlight";
  runtimeInputs = [coreutils brillo];
  text = builtins.readFile ./backlight.sh;
}
