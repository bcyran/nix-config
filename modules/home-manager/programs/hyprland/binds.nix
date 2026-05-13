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
        (
          if cfg.withHy3
          then "$mod SHIFT, ${ws.fst}, hy3:movetoworkspace, ${ws.snd}, follow"
          else "$mod SHIFT, ${ws.fst}, movetoworkspace, ${ws.snd}"
        )
      ])
      (lib.lists.zipLists
        keys
        names));
  in
    binds;

  # Common binds that don't change between noctalia and my custom shell
  commonBinds =
    [
      (
        if cfg.withHy3
        then "$mod SHIFT, q, hy3:killactive,"
        else "$mod SHIFT, q, killactive,"
      )
      "$mod, f, fullscreen"
      "$mod SHIFT, f, togglefloating,"
      "$mod SHIFT, p, pseudo,"
      "$mod SHIFT, x, pin,"
    ]
    ++ (
      if cfg.withHy3
      then [
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
      ]
      else [
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
      ]
    )
    ++ (
      if cfg.withHy3
      then [
        "$mod, h, hy3:movefocus, l, visible"
        "$mod, l, hy3:movefocus, r, visible"
        "$mod, k, hy3:movefocus, u, visible"
        "$mod, j, hy3:movefocus, d, visible"
      ]
      else [
        "$mod, h, movefocus, l"
        "$mod, l, movefocus, r"
        "$mod, k, movefocus, u"
        "$mod, j, movefocus, d"
      ]
    )
    ++ [
      "$mod, u, focusmonitor, l"
      "$mod, i, focusmonitor, r"

      "$mod, d, togglespecialworkspace, dropdown"
      "$mod, tab, focuscurrentorlast,"
    ]
    ++ (
      if cfg.withHy3
      then [
        "$mod SHIFT, h, hy3:movewindow, l"
        "$mod SHIFT, l, hy3:movewindow, r"
        "$mod SHIFT, k, hy3:movewindow, u"
        "$mod SHIFT, j, hy3:movewindow, d"
      ]
      else [
        "$mod SHIFT, h, movewindoworgroup, l"
        "$mod SHIFT, l, movewindoworgroup, r"
        "$mod SHIFT, k, movewindoworgroup, u"
        "$mod SHIFT, j, movewindoworgroup, d"
      ]
    )
    ++ [
      "$mod, mouse_down, workspace, e+1"
      "$mod, mouse_up, workspace, e-1"
    ]
    ++ (
      if cfg.withHy3
      then [
        "$mod, mouse_left, hy3:focustab, l"
        "$mod, mouse_right, hy3:focustab, r"
      ]
      else [
        "$mod, mouse_left, changegroupactive, b"
        "$mod, mouse_right, changegroupactive, f"
      ]
    )
    ++ [
      "$mod, s, exec, ${execWrapper} scr area"
      "$mod SHIFT, s, exec, ${execWrapper} scr active"
      "$mod CONTROL, s, exec, ${execWrapper} scr output"

      "$mod, return, exec, ${execWrapper} kitty"
      "$mod SHIFT, return, exec, ${execWrapper} kitty --class terminal-floating"
      "$mod, Y, exec, ${execWrapper} firefox"
      "$mod, N, exec, ${execWrapper} thunar"
    ];

  # Noctalia shell binds
  noctaliaShellBinds = let
    ipc = "noctalia-shell ipc call";
    noctaliaExecWrapper = "${execWrapper} ${ipc}";
  in [
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
  ];

  # Noctalia locked binds (active on lock screen, non-repeatable)
  noctaliaLockedBinds = let
    ipc = "noctalia-shell ipc call";
    noctaliaExecWrapper = "${execWrapper} ${ipc}";
  in [
    ",XF86AudioMute, exec, ${noctaliaExecWrapper} volume muteOutput"
  ];

  # Noctalia locked repeatable binds (active on lock screen, repeat while held)
  noctaliaRepeatableLockedBinds = let
    ipc = "noctalia-shell ipc call";
    noctaliaExecWrapper = "${execWrapper} ${ipc}";
  in [
    ",XF86AudioRaiseVolume, exec, ${noctaliaExecWrapper} volume increase"
    ",XF86AudioLowerVolume, exec, ${noctaliaExecWrapper} volume decrease"

    ",XF86MonBrightnessDown, exec, ${noctaliaExecWrapper} brightness decrease"
    ",XF86MonBrightnessUp, exec, ${noctaliaExecWrapper} brightness increase"
  ];

  # Non-noctalia shell binds
  defaultShellBinds = [
    "$mod, slash, exec, ${execWrapper} playerctl play-pause"
    "$mod, comma, exec, ${execWrapper} playerctl previous"
    "$mod, period, exec, ${execWrapper} playerctl next"

    "CONTROL, space, exec, ${execWrapper} swaync-client --toggle-panel"
    "CONTROL, escape, exec, ${execWrapper} swaync-client --close-latest"

    "$mod, space, exec, ${execWrapper} anyrun"
    "$mod SHIFT, m, exec, ${execWrapper} loginctl lock-session"
  ];

  # Non-noctalia locked binds (active on lock screen, non-repeatable)
  defaultLockedBinds = [
    ",XF86AudioMute, exec, ${execWrapper} volume toggle"
  ];

  # Non-noctalia locked repeatable binds (active on lock screen, repeat while held)
  defaultRepeatableLockedBinds = [
    ",XF86AudioRaiseVolume, exec, ${execWrapper} volume up"
    ",XF86AudioLowerVolume, exec, ${execWrapper} volume down"

    ",XF86MonBrightnessDown, exec, ${execWrapper} backlight down 10"
    ",XF86MonBrightnessUp, exec, ${execWrapper} backlight up 10"
  ];

  # Select shell-specific binds
  shellBinds =
    if cfg.withNoctalia
    then noctaliaShellBinds
    else defaultShellBinds;

  lockedBinds =
    if cfg.withNoctalia
    then noctaliaLockedBinds
    else defaultLockedBinds;

  repeatableLockedBinds =
    if cfg.withNoctalia
    then noctaliaRepeatableLockedBinds
    else defaultRepeatableLockedBinds;
in {
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      settings = {
        bind = commonBinds ++ shellBinds ++ workspaceBinds;
        bindl = lockedBinds;
        bindel = repeatableLockedBinds;
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
