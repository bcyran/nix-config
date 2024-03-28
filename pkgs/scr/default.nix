{
  writeShellApplication,
  hyprland,
  coreutils,
  libnotify,
  satty,
  grimblast,
  xdg-user-dirs,
}:
writeShellApplication {
  name = "scr";
  runtimeInputs = [hyprland coreutils libnotify satty grimblast xdg-user-dirs];
  text = builtins.readFile ./scr.sh;
}
