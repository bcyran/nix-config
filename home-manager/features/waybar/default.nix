{
  programs.waybar.enable = true;
  # TODO: Create waybar modules using `writeShellApplication`
  xdg.configFile.waybar = {
    source = ./files;
    recursive = true;
  };
}
