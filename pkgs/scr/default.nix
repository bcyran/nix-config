{
  writeShellApplication,
  hyprland,
  libnotify,
  satty,
  grimblast,
  xdg-user-dirs,
}:
writeShellApplication {
  name = "scr";
  runtimeInputs = [hyprland libnotify satty grimblast xdg-user-dirs];
  text = builtins.readFile ./scr.sh;
}
