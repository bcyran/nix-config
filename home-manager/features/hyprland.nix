{
  wayland.windowManager.hyprland = {
    enable = true;
    systemd = {
      enable = true;
    };
    settings = {
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
        "col.active_border" = "rgb(e5c07b)";
        "col.inactive_border" = "rgb(373b43)";
      };
      group = {
        focus_removed_window = true;
        insert_after_current = true;
        "col.border_active" = "rgb(e5c07b)";
        "col.border_inactive" = "rgb(373b43)";
        groupbar = {
          render_titles = false;
          gradients = false;
          "col.active" = "rgb(e5c07b)";
          "col.inactive" = "rgb(373b43)";
          text_color = "rgb(abb2bf)";
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
      bind = [
        "$mod SHIFT, q, killactive,"
        "$mod SHIFT, e, exit, "
        "$mod, f, fullscreen"
        "$mod SHIFT, f, togglefloating,"
        "$mod SHIFT, p, pseudo,"
        "$mod SHIFT, x, pin,"
        "$mod, v, togglesplit,"
        "$mod, d, exec, hyprctl keyword general:layout dwindle"
        "$mod SHIFT, d, exec, hyprctl keyword general:layout master"
        "$mod, o, changegroupactive, b"
        "$mod, p, changegroupactive, f"
        "$mod, t, togglegroup"
        "$mod SHIFT, t, moveoutofgroup"
        "$mod CONTROL, h, moveintogroup, l"
        "$mod CONTROL, l, moveintogroup, r"
        "$mod CONTROL, k, moveintogroup, u"
        "$mod CONTROL, j, moveintogroup, d"

        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"
        "$mod, minus, workspace, 11"

        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 10"
        "$mod SHIFT, minus, movetoworkspace, 11"

        "$mod, h, movefocus, l"
        "$mod, l, movefocus, r"
        "$mod, k, movefocus, u"
        "$mod, j, movefocus, d"
        "$mod, u, focusmonitor, l"
        "$mod, i, focusmonitor, r"

        "$mod SHIFT, h, swapwindow, l"
        "$mod SHIFT, l, swapwindow, r"
        "$mod SHIFT, k, swapwindow, u"
        "$mod SHIFT, j, swapwindow, d"

        "$mod, mouse_down, workspace, e+1"
        "$mod, mouse_up, workspace, e-1"

        "$mod, mouse_left, changegroupactive, b"
        "$mod, mouse_right, changegroupactive, f"

        "$mod, equal, exec, scr output"
        "$mod CONTROL, equal, exec, scr area"
        "$mod SHIFT, equal, exec, scr active"

        "$mod, slash, exec, playerctl play-pause"
        "$mod, comma, exec, playerctl previous"
        "$mod, period, exec, playerctl next"

        ",XF86AudioRaiseVolume, exec, volume up"
        ",XF86AudioLowerVolume, exec, volume down"
        ",XF86AudioMute, exec, volume toggle"

        ",XF86MonBrightnessUp, exec, backlight up 10"
        ",XF86MonBrightnessDown, exec, backlight down 10"

        "CONTROL, space, exec, dunstctl close"
        "CONTROL, escape, exec, dunstctl history-pop"

        "$mod, space, exec, ~/.config/rofi/scripts/appmenu.sh"
        "$mod SHIFT, space, exec, ~/.config/rofi/scripts/filesearch.sh"
        "$mod CONTROL, space, exec, ~/.config/rofi/scripts/runmenu.sh"
        "$mod SHIFT, backspace, exec, ~/.config/rofi/scripts/powermenu.sh"
        "$mod, c, exec, ~/.config/rofi/scripts/calc.sh"
        "$mod, return, exec, alacritty"
        "$mod SHIFT, return, exec, alacritty --class terminal-floating"
        "$mod, Y, exec, firefox"
        "$mod, N, exec, thunar"
      ];
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
      "exec-once" = [
        "~/.config/waybar/launch.sh"
      ];
    };
    extraConfig = ''
      bind=ALT,R,submap,resize
      submap=resize
      binde=,l,resizeactive,20 0
      binde=,h,resizeactive,-20 0
      binde=,k,resizeactive,0 -20
      binde=,j,resizeactive,0 20
      bind=,escape,submap,reset
      submap=reset

      bind=ALT,M,submap,move
      submap=move
      binde=,l,moveactive,20 0
      binde=,h,moveactive,-20 0
      binde=,k,moveactive,0 -20
      binde=,j,moveactive,0 20
      bind=,escape,submap,reset
      submap=reset

      bind=ALT,escape,submap,passthrough
      submap=passthrough
      bind=ALT,escape,submap,reset
      submap=reset
    '';
  };
}
