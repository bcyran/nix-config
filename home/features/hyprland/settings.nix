{
  pkgs,
  config,
  ...
}: let
  alacrittyBin = "${pkgs.alacritty}/bin/alacritty";
  inherit (config.colorScheme) palette;
in {
  wayland.windowManager.hyprland.settings = {
    "$mod" = "ALT";
    "$monitorL" = "eDP-1";
    "$monitorC" = "DP-6";
    "$monitorR" = "DP-7";
    env = [
      "XCURSOR_SIZE,24"
      "QT_QPA_PLATFORM,wayland"
    ];
    monitor = [
      "eDP-1, 1920x1080@60, 0x0, 1"
      ",preferred, auto, 1"
      # "desc:California Institute of Technology 0x1402, 2880x1800@60, 0x325, 1.5, transform, 0"
      # "desc:Dell Inc. DELL PD2421D FJWHGC3, 2560x1440@60, 1920x325, 1.0, transform, 0"
      # "desc:Dell Inc. DELL PD2421D CGSHL93, 2560x1440@60, 4480x0, 1.0, transform, 3"
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
      new_is_master = false;
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
    # cursor = {
    #   inactive_timeout = 60;
    #   hide_on_key_press = true;
    #   persistent_warps = true;
    # };
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
}
