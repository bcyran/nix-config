{
  writeShellApplication,
  hyprland,
  coreutils,
  libnotify,
  satty,
  grimblast,
  xdg-user-dirs,
  glib,
}:
writeShellApplication {
  name = "scr";
  runtimeInputs = [hyprland coreutils libnotify satty grimblast xdg-user-dirs glib];
  text = builtins.readFile ./scr.sh;
}
