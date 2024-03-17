{pkgs, ...}: {
  backlight = pkgs.writeShellApplication {
    name = "backlight";
    runtimeInputs = with pkgs; [light];
    text = builtins.readFile ./files/backlight.sh;
  };
  volume = pkgs.writeShellApplication {
    name = "volume";
    runtimeInputs = with pkgs; [wireplumber bc];
    text = builtins.readFile ./files/volume.sh;
  };
  # TODO: Make `satty` package
  # scr = pkgs.writeShellApplication {
  #   name = "scr";
  #   runtimeInputs = with pkgs; [grimblast satty hyprland];
  #   text = builtins.readFile ./files/volume.sh;
  # };
  wallpaper = pkgs.writeShellApplication {
    name = "wallpaper";
    text = builtins.readFile ./files/wallpaper.sh;
  };
}
