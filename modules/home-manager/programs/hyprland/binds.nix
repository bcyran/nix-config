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
        "$mod SHIFT, ${ws.fst}, hy3:movetoworkspace, ${ws.snd}, follow"
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
            "$mod SHIFT, q, hy3:killactive,"
            "$mod, f, fullscreen"
            "$mod SHIFT, m, fullscreenstate, 1"
            "$mod SHIFT, f, togglefloating,"
            "$mod SHIFT, p, pseudo,"
            "$mod SHIFT, x, pin,"
            "$mod, v, hy3:makegroup, v"
            "$mod, c, hy3:makegroup, h"
            "$mod, x, hy3:changegroup, opposite"
            "$mod, a, hy3:changefocus, raise"
            "$mod, z, hy3:changefocus, lower"
            "$mod, o, hy3:focustab, l"
            "$mod, p, hy3:focustab, r"
            "$mod, t, hy3:makegroup, tab"
            "$mod SHIFT, t, hy3:changegroup, toggletab"
            "$mod, g, hy3:togglefocuslayer, nowarp"
            "$mod, e, hy3:expand, expand"
            "$mod SHIFT, e, hy3:expand, shrink"

            "$mod, h, hy3:movefocus, l, visible"
            "$mod, l, hy3:movefocus, r, visible"
            "$mod, k, hy3:movefocus, u, visible"
            "$mod, j, hy3:movefocus, d, visible"
            "$mod, u, focusmonitor, l"
            "$mod, i, focusmonitor, r"

            "$mod SHIFT, h, hy3:movewindow, l"
            "$mod SHIFT, l, hy3:movewindow, r"
            "$mod SHIFT, k, hy3:movewindow, u"
            "$mod SHIFT, j, hy3:movewindow, d"

            "$mod, mouse_down, workspace, e+1"
            "$mod, mouse_up, workspace, e-1"

            "$mod, mouse_left, hy3:focustab, l"
            "$mod, mouse_right, hy3:focustab, r"

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
            "$mod, Y, exec, zen"
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
