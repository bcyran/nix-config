{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.my.programs.hyprland;

  thunar = pkgs.xfce.thunar.override {thunarPlugins = with pkgs; [xfce.thunar-volman xfce.thunar-archive-plugin];};

  hyprctlBin = "${pkgs.hyprland}/bin/hyprctl";
  alacrittyBin = lib.getExe pkgs.alacritty;
  playerctlBin = lib.getExe pkgs.playerctl;
  swayncClientBin = "${pkgs.swaynotificationcenter}/bin/swaync-client";
  firefoxBin = lib.getExe pkgs.firefox;
  thunarBin = "${thunar}/bin/thunar";
  backlightBin = lib.getExe pkgs.my.backlight;
  volumeBin = lib.getExe pkgs.my.volume;
  scrBin = lib.getExe pkgs.my.scr;

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
            "$mod SHIFT, m, fakefullscreen"
            "$mod SHIFT, f, togglefloating,"
            "$mod SHIFT, p, pseudo,"
            "$mod SHIFT, x, pin,"
            "$mod, v, togglesplit,"
            "$mod, d, exec, ${hyprctlBin} keyword general:layout dwindle"
            "$mod SHIFT, d, exec, ${hyprctlBin} keyword general:layout master"
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

            "$mod, s, exec, ${scrBin} output"
            "$mod CONTROL, s, exec, ${scrBin} area"
            "$mod SHIFT, s, exec, ${scrBin} active"

            "$mod, slash, exec, ${playerctlBin} play-pause"
            "$mod, comma, exec, ${playerctlBin} previous"
            "$mod, period, exec, ${playerctlBin} next"

            ",XF86AudioRaiseVolume, exec, ${volumeBin} up"
            ",XF86AudioLowerVolume, exec, ${volumeBin} down"
            ",XF86AudioMute, exec, ${volumeBin} toggle"

            ",XF86MonBrightnessDown, exec, ${backlightBin} down 10"
            ",XF86MonBrightnessUp, exec, ${backlightBin} up 10"

            "CONTROL, space, exec, ${swayncClientBin} --toggle-panel"
            "CONTROL, escape, exec, ${swayncClientBin} --close-latest"

            "$mod, space, exec, anyrun"
            "$mod, return, exec, ${alacrittyBin}"
            "$mod SHIFT, return, exec, ${alacrittyBin} --class terminal-floating"
            "$mod, Y, exec, ${firefoxBin}"
            "$mod, N, exec, ${thunarBin}"
          ]
          ++ workspaceBinds;
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
  };
}
