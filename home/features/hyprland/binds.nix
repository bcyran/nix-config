{
  pkgs,
  config,
  ...
}: let
  rofi = import ../rofi {inherit pkgs config;};
  appmenuBin = "${rofi.appmenu}/bin/rofi-appmenu";
  runmenuBin = "${rofi.runmenu}/bin/rofi-runmenu";
  powermenuBin = "${rofi.powermenu}/bin/rofi-powermenu";
  calcBin = "${rofi.calc}/bin/rofi-calc";
in {
  wayland.windowManager.hyprland = {
    settings = {
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

        "$mod, space, exec, ${appmenuBin}"
        "$mod CONTROL, space, exec, ${runmenuBin}"
        "$mod SHIFT, backspace, exec, ${powermenuBin}"
        "$mod, c, exec, ${calcBin}"
        "$mod, return, exec, alacritty"
        "$mod SHIFT, return, exec, alacritty --class terminal-floating"
        "$mod, Y, exec, firefox"
        "$mod, N, exec, thunar"
      ];
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
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
