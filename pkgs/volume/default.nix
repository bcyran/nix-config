{
  writeShellApplication,
  wireplumber,
  bc,
}:
writeShellApplication {
  name = "volume";
  runtimeInputs = [wireplumber bc];
  text = builtins.readFile ./volume.sh;
}
