{
  config,
  lib,
  ...
}: let
  cfg = config.my.programs.hyprland;
  inherit (cfg) execWrapper;

  workspaceBinds = let
    # Keys: 1 - 9, 0, -
    keys = map (x: builtins.toString x) (lib.range 1 9) ++ ["0" "minus"];
    # Names: 1 - 11
    names = map (x: builtins.toString x) (lib.range 1 11);
    binds = builtins.concatLists (map (ws: [
        "$mod, ${ws.fst}, workspace, ${ws.snd}"
        "$mod SHIFT, ${ws.fst}, movetoworkspace, ${ws.snd}"
      ])
      (lib.lists.zipLists keys names));
  in
    binds;

  noctaliaExecWrapper = "${execWrapper} noctalia-shell ipc call";
in {
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      settings = {
        bind =
          [
            "$mod SHIFT, q, killactive,"
            "$mod, f, fullscreen"
            "$mod SHIFT, f, togglefloating,"
            "$mod SHIFT, p, pseudo,"
            "$mod SHIFT, x, pin,"
            "$mod, v, layoutmsg, preselect d"
            "$mod, c, layoutmsg, preselect r"
            "$mod, t, togglegroup"
            "$mod, x, moveoutofgroup"
            "$mod, o, changegroupactive, b"
            "$mod, p, changegroupactive, f"
            "$mod SHIFT, o, movegroupwindow, b"
            "$mod SHIFT, p, movegroupwindow, f"
            "$mod, g, cyclenext, tiled"
            "$mod SHIFT, g, cyclenext, floating"
            "$mod, h, movefocus, l"
            "$mod, l, movefocus, r"
            "$mod, k, movefocus, u"
            "$mod, j, movefocus, d"
            "$mod, u, focusmonitor, l"
            "$mod, i, focusmonitor, r"

            "$mod, d, togglespecialworkspace, dropdown"
            "$mod, tab, focuscurrentorlast,"
            "$mod SHIFT, h, movewindoworgroup, l"
            "$mod SHIFT, l, movewindoworgroup, r"
            "$mod SHIFT, k, movewindoworgroup, u"
            "$mod SHIFT, j, movewindoworgroup, d"
            "$mod, mouse_down, workspace, e+1"
            "$mod, mouse_up, workspace, e-1"
            "$mod, mouse_left, changegroupactive, b"
            "$mod, mouse_right, changegroupactive, f"

            "$mod, s, exec, ${execWrapper} scr area"
            "$mod SHIFT, s, exec, ${execWrapper} scr active"
            "$mod CONTROL, s, exec, ${execWrapper} scr output"

            "$mod, return, exec, ${execWrapper} kitty"
            "$mod SHIFT, return, exec, ${execWrapper} kitty --class terminal-floating"
            "$mod, Y, exec, ${execWrapper} firefox"
            "$mod, N, exec, ${execWrapper} thunar"

            "$mod, slash, exec, ${noctaliaExecWrapper} media playPause"
            "$mod SHIFT, slash, exec, ${noctaliaExecWrapper} media toggle"
            "$mod, comma, exec, ${noctaliaExecWrapper} media previous"
            "$mod, period, exec, ${noctaliaExecWrapper} media next"

            "CONTROL, space, exec, ${noctaliaExecWrapper} notifications toggleHistory"
            "CONTROL SHIFT, space, exec, ${noctaliaExecWrapper} notifications clear"
            "CONTROL, escape, exec, ${noctaliaExecWrapper} notifications dismissAll"

            "$mod, space, exec, ${noctaliaExecWrapper} launcher toggle"
            "$mod, w, exec, ${noctaliaExecWrapper} launcher windows"
            "$mod SHIFT, v, exec, ${noctaliaExecWrapper} launcher clipboard"
            "$mod, grave, exec, ${noctaliaExecWrapper} settings toggle"
            "$mod SHIFT, space, exec, ${noctaliaExecWrapper} controlCenter toggle"
            "$mod SHIFT, m, exec, ${noctaliaExecWrapper} lockScreen lock"
          ]
          ++ workspaceBinds;
        # Active on lock screen, non-repeatable
        bindl = [
          ",XF86AudioMute, exec, ${noctaliaExecWrapper} volume muteOutput"
        ];
        # Active on lock screen, repeat while held
        bindel = [
          ",XF86AudioRaiseVolume, exec, ${noctaliaExecWrapper} volume increase"
          ",XF86AudioLowerVolume, exec, ${noctaliaExecWrapper} volume decrease"

          ",XF86MonBrightnessDown, exec, ${noctaliaExecWrapper} brightness decrease"
          ",XF86MonBrightnessUp, exec, ${noctaliaExecWrapper} brightness increase"
        ];
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
