{
  writeShellApplication,
  wireplumber,
  coreutils,
  bc,
}:
writeShellApplication {
  name = "volume";
  runtimeInputs = [wireplumber coreutils bc];
  text = builtins.readFile ./volume.sh;
}
