{
  writeShellApplication,
  fio,
  jq,
}:
writeShellApplication {
  name = "fio-bench";
  runtimeInputs = [fio jq];
  text = builtins.readFile ./fio-bench.sh;
}
