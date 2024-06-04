{pkgs, ...}: let
  # Config files: common, default, multi-monitor
  configCommon = pkgs.writeTextFile {
    name = "config-common.json";
    text = builtins.readFile ./files/common.json;
  };
  configDefault = pkgs.substituteAll {
    name = "config-default.json";
    src = ./files/config-default.json;
    configCommonPath = configCommon;
  };
  configMulti = pkgs.substituteAll {
    name = "config-multi.json";
    src = ./files/config-multi.json;
    configCommonPath = configCommon;
  };
  # Module scripts
  backlightModule = pkgs.writeShellApplication {
    name = "waybar-backlight";
    runtimeInputs = with pkgs; [my.backlight inotifyTools];
    text = builtins.readFile ./files/modules/light.sh;
  };
  mprisModule = pkgs.writeShellApplication {
    name = "waybar-mpris";
    runtimeInputs = with pkgs; [playerctl];
    text = builtins.readFile ./files/modules/mpris.sh;
  };
  # Launcher script
  launcherRendered = pkgs.substituteAll {
    name = "launch";
    src = ./files/launch.sh;
    configDefaultPath = configDefault;
    configMultiPath = configMulti;
  };
  launcher = pkgs.writeShellApplication {
    name = "waybar-launch";
    runtimeInputs = with pkgs; [waybar hyprland killall gnugrep backlightModule mprisModule];
    text = builtins.readFile launcherRendered;
  };
in {
  programs.waybar.enable = true;
  xdg.configFile."waybar/style.css" = {
    source = ./files/style.css;
  };
  systemd.user.services.waybar = {
    Unit = {
      Description = "Waybar panels";
      PartOf = ["graphical-session.target"];
      After = ["graphical-session-pre.target"];
    };
    Service = {
      ExecStart = "${launcher}/bin/waybar-launch";
      ExecReload = "${pkgs.coreutils}/bin/kill -SIGUSR2 $MAINPID";
      Restart = "on-failure";
      KillMode = "mixed";
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };
}
