{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (config.colorScheme) palette;
  killBin = "${lib.getBin pkgs.coreutils}/bin/kill";
  sleepBin = "${lib.getBin pkgs.coreutils}/bin/sleep";
  # Config files: common, default, multi-monitor
  configCommon = pkgs.substituteAll {
    name = "config-common.json";
    src = ./files/common.json;
    wirelessNetworkInterface = config.my.hardware.networkInterfaces.wireless;
  };
  configDefault = pkgs.substituteAll {
    name = "config-default.json";
    src = ./files/config-default.json;
    configCommonPath = configCommon;
  };
  monitorByIdx = idx: builtins.elemAt config.my.hardware.monitors idx;
  monitorOutputsJsonStr = m:
    if m.altOutput == null
    then ''"${m.output}"''
    else ''"${m.output}", "${m.altOutput}"'';
  configMulti = pkgs.substituteAll {
    name = "config-multi.json";
    src = ./files/config-multi.json;
    configCommonPath = configCommon;
    monitorLeft = monitorOutputsJsonStr (monitorByIdx 0);
    monitorCenter = monitorOutputsJsonStr (monitorByIdx 1);
    monitorRight = monitorOutputsJsonStr (monitorByIdx 2);
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
  philipstvModule = pkgs.writeShellApplication {
    name = "waybar-philipstv";
    runtimeInputs = with pkgs; [my.philipstv];
    text = builtins.readFile ./files/modules/philipstv.sh;
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
    runtimeInputs = with pkgs; [
      waybar
      hyprland
      killall
      gnugrep
      coreutils
      systemd
      backlightModule
      mprisModule
      playerctl
      philipstvModule
      my.philipstv
      my.philipstv-gui
    ];
    text = builtins.readFile launcherRendered;
  };
  launcherBin = lib.getExe launcher;
in {
  programs.waybar.enable = true;
  xdg.configFile."waybar/style.css" = {
    source = ./files/style.css;
  };
  xdg.configFile."waybar/colors.css" = {
    text = ''
      @define-color base00 #${palette.base00};
      @define-color base01 #${palette.base01};
      @define-color base02 #${palette.base02};
      @define-color base03 #${palette.base03};
      @define-color base04 #${palette.base04};
      @define-color base05 #${palette.base05};
      @define-color base06 #${palette.base06};
      @define-color base07 #${palette.base07};
      @define-color base08 #${palette.base08};
      @define-color base09 #${palette.base09};
      @define-color base0A #${palette.base0A};
      @define-color base0B #${palette.base0B};
      @define-color base0C #${palette.base0C};
      @define-color base0D #${palette.base0D};
      @define-color base0E #${palette.base0E};
      @define-color base0F #${palette.base0F};
      @define-color base10 #${palette.base10};
      @define-color base11 #${palette.base11};
      @define-color base12 #${palette.base12};
      @define-color base13 #${palette.base13};
      @define-color base14 #${palette.base14};
      @define-color base15 #${palette.base15};
      @define-color base16 #${palette.base16};
      @define-color base17 #${palette.base17};

      @define-color accent_primary #${palette.accentPrimary};
      @define-color accent_secondary #${palette.accentSecondary};
      @define-color warning #${palette.warning};
      @define-color error #${palette.error};
    '';
  };
  systemd.user.services.waybar = {
    Unit = {
      Description = "Waybar panels";
      PartOf = ["tray.target"];
      After = ["graphical-session-pre.target"];
      StartLimitBurst = 15;
    };
    Service = {
      Type = "notify";
      NotifyAccess = "all";
      ExecStartPre = "${sleepBin} 2";
      ExecStart = launcherBin;
      ExecReload = "${killBin} -SIGUSR2 $MAINPID";
      Restart = "on-failure";
      RestartSec = 2;
      KillMode = "mixed";
    };
    Install = {
      RequiredBy = ["tray.target"];
    };
  };
}
