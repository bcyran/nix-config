{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  inherit (config.colorScheme) palette;
  cfg = config.my.programs.hyprland;

  alacrittyBin = lib.getExe pkgs.alacritty;
  monitorId = m:
    if m.id_by_output
    then "${m.output}"
    else "desc:${m.description}";
  monitorByIdx = idx: builtins.elemAt config.my.hardware.monitors idx;
in {
  config = mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = {
      "$mod" = "ALT";
      "$monitorL" = monitorId (monitorByIdx 0);
      "$monitorC" = monitorId (monitorByIdx 1);
      "$monitorR" = monitorId (monitorByIdx 2);
      env = [
        "XCURSOR_SIZE,24"
        "QT_QPA_PLATFORM,wayland"
      ];
      monitor = let
        mon = m: "${monitorId m}, ${toString m.width}x${toString m.height}@${toString m.refreshRate}, ${toString m.x}x${toString m.y}, ${toString m.scale}, transform, ${toString m.transform}";
      in
        (map mon config.my.hardware.monitors)
        ++ [
          ",preferred, auto, 1"
        ];
      input = {
        kb_layout = "pl";
        follow_mouse = 1;
        touchpad = {
          natural_scroll = "no";
        };
        sensitivity = 0.4;
        accel_profile = "adaptive";
        repeat_rate = 60;
        repeat_delay = 300;
      };
      general = {
        layout = "dwindle";
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgb(${palette.accentPrimary})";
        "col.inactive_border" = "rgb(${palette.base01})";
      };
      group = {
        focus_removed_window = true;
        insert_after_current = true;
        "col.border_active" = "rgb(${palette.accentPrimary})";
        "col.border_inactive" = "rgb(${palette.base01})";
        groupbar = {
          render_titles = false;
          gradients = false;
          "col.active" = "rgb(${palette.accentPrimary})";
          "col.inactive" = "rgb(${palette.base01})";
          text_color = "rgb(${palette.base05})";
        };
      };
      decoration = {
        rounding = 3;
        active_opacity = 0.93;
        inactive_opacity = 0.93;
        fullscreen_opacity = 1.0;
        drop_shadow = "yes";
        shadow_range = 4;
        shadow_render_power = 3;
        "col.shadow" = "rgb(1a1a1a)";
        blur = {
          enabled = "yes";
          size = 5;
          passes = 2;
          new_optimizations = "on";
        };
      };
      animations = {
        enabled = "yes";
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 3, myBezier"
          "windowsOut, 1, 3, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 0"
        ];
      };
      dwindle = {
        pseudotile = "yes";
        preserve_split = "yes";
        force_split = 2;
      };
      master = {
        new_status = "slave";
      };
      gestures = {
        workspace_swipe = true;
      };
      binds = {
        workspace_back_and_forth = true;
      };
      misc = {
        mouse_move_enables_dpms = false;
        key_press_enables_dpms = false;
        force_default_wallpaper = 0;
        animate_manual_resizes = true;
      };
      cursor = {
        inactive_timeout = 60;
        hide_on_key_press = true;
        persistent_warps = true;
      };
      workspace = [
        "1, monitor:$monitorC, default:true"
        "2, monitor:$monitorC"
        "3, monitor:$monitorC"
        "4, monitor:$monitorC"
        "5, monitor:$monitorR, default:true"
        "6, monitor:$monitorR"
        "7, monitor:$monitorR"
        "8, monitor:$monitorL, default:true"
        "9, monitor:$monitorL"
        "10, monitor:$monitorL"
        "11, monitor:$monitorC"
      ];
      exec-once = [
        "${alacrittyBin} --class terminal-workspace"
      ];
    };
  };
}
