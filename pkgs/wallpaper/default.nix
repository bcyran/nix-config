{writeShellApplication}:
writeShellApplication {
  name = "wallpaper";
  text = builtins.readFile ./wallpaper.sh;
}
