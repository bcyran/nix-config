{
  config,
  lib,
  ...
}: let
  cfg = config.my.programs.hyprland;

  workspaceBinds = let
    # Keys: 1 - 9, 0, -
    keys = map (x: builtins.toString x) (lib.range 1 9) ++ ["0" "minus"];
    # Names: 1 - 11
    names = map (x: builtins.toString x) (lib.range 1 11);
    binds = builtins.concatLists (map (ws: [
        "$mod, ${ws.fst}, workspace, ${ws.snd}"
        "$mod SHIFT, ${ws.fst}, movetoworkspace, ${ws.snd}"
      ])
      (lib.lists.zipLists
        keys
        names));
  in
    binds;
in {
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      settings = {
        bind =
          [
            "$mod SHIFT, q, killactive,"
            "$mod SHIFT, e, exit, "
            "$mod, f, fullscreen"
            "$mod SHIFT, m, fullscreenstate, 1"
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

            "$mod, s, exec, scr output"
            "$mod CONTROL, s, exec, scr area"
            "$mod SHIFT, s, exec, scr active"

            "$mod, slash, exec, playerctl play-pause"
            "$mod, comma, exec, playerctl previous"
            "$mod, period, exec, playerctl next"

            ",XF86AudioRaiseVolume, exec, volume up"
            ",XF86AudioLowerVolume, exec, volume down"
            ",XF86AudioMute, exec, volume toggle"

            ",XF86MonBrightnessDown, exec, backlight down 10"
            ",XF86MonBrightnessUp, exec, backlight up 10"

            "CONTROL, space, exec, swaync-client --toggle-panel"
            "CONTROL, escape, exec, swaync-client --close-latest"

            "$mod, space, exec, anyrun"
            "$mod, return, exec, alacritty"
            "$mod SHIFT, return, exec, alacritty --class terminal-floating"
            "$mod, Y, exec, firefox"
            "$mod, N, exec, thunar"
          ]
          ++ workspaceBinds;
        bindm = [
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
        ];
      };
      extraConfig = ''
        bind=SUPER,R,submap,resize
        submap=resize
        binde=,l,resizeactive,20 0
        binde=,h,resizeactive,-20 0
        binde=,k,resizeactive,0 -20
        binde=,j,resizeactive,0 20
        bind=,escape,submap,reset
        submap=reset

        bind=SUPER,M,submap,move
        submap=move
        binde=,l,moveactive,20 0
        binde=,h,moveactive,-20 0
        binde=,k,moveactive,0 -20
        binde=,j,moveactive,0 20
        bind=,escape,submap,reset
        submap=reset

        bind=SUPER,escape,submap,passthrough
        submap=passthrough
        bind=SUPER,escape,submap,reset
        submap=reset
      '';
    };
  };
}
