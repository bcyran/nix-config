{
  pkgs,
  config,
  ...
}: let
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
  xdg.configFile."waybar/colors.css" = {
    text = ''
      @define-color bg #${config.colorScheme.palette.bg};
      @define-color bg_dark #${config.colorScheme.palette.bg_dark};
      @define-color bg_highlight #${config.colorScheme.palette.bg_highlight};
      @define-color fg #${config.colorScheme.palette.fg};
      @define-color fg_dark #${config.colorScheme.palette.fg_dark};

      @define-color base00 #${config.colorScheme.palette.base00};
      @define-color base01 #${config.colorScheme.palette.base01};
      @define-color base03 #${config.colorScheme.palette.base02};
      @define-color base02 #${config.colorScheme.palette.base03};
      @define-color base04 #${config.colorScheme.palette.base04};
      @define-color base05 #${config.colorScheme.palette.base05};
      @define-color base06 #${config.colorScheme.palette.base06};
      @define-color base07 #${config.colorScheme.palette.base07};
      @define-color base08 #${config.colorScheme.palette.base08};
      @define-color base09 #${config.colorScheme.palette.base09};
      @define-color base0A #${config.colorScheme.palette.base0A};
      @define-color base0B #${config.colorScheme.palette.base0B};
      @define-color base0C #${config.colorScheme.palette.base0C};
      @define-color base0D #${config.colorScheme.palette.base0D};
      @define-color base0E #${config.colorScheme.palette.base0E};
      @define-color base0F #${config.colorScheme.palette.base0F};
    '';
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
