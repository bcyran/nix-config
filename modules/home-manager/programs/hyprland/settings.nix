{
  config,
  lib,
  ...
}: let
  inherit (config.colorScheme) palette;
  cfg = config.my.programs.hyprland;
  inherit (cfg) execWrapper;
  kanshiCfg = config.my.programs.kanshi;

  monitorId = m:
    if m.idByOutput
    then "${m.output}"
    else "desc:${m.description}";
  monitorByIdx = idx: builtins.elemAt config.my.hardware.monitors idx;
  monitorConfig = let
    monOpts = m:
      if m.enable
      then [
        "${monitorId m}"
        "${toString m.width}x${toString m.height}@${toString m.refreshRate}"
        "${toString m.x}x${toString m.y}"
        "${toString m.scale}"
        "transform, ${toString m.transform}"
        "bitdepth, ${toString m.bitDepth}"
      ]
      else [
        "${monitorId m}"
        "disable"
      ];
    monOptsStr = m: builtins.concatStringsSep ", " (monOpts m);
  in
    (map monOptsStr config.my.hardware.monitors)
    ++ [
      ",preferred, auto, 1"
    ];
in {
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = {
      "$mod" = "SUPER";
      "$monitorL" = monitorId (monitorByIdx 0);
      "$monitorC" = monitorId (monitorByIdx 1);
      "$monitorR" = monitorId (monitorByIdx 2);
      monitor =
        if !kanshiCfg.enable
        then monitorConfig
        else [];
      input = {
        kb_layout = "pl";
        follow_mouse = 1;
        mouse_refocus = false;
        touchpad = {
          natural_scroll = "no";
        };
        sensitivity = 0.4;
        accel_profile = "adaptive";
        repeat_rate = 60;
        repeat_delay = 300;
      };
      general = {
        layout = "hy3";
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgb(${palette.accentPrimary})";
        "col.inactive_border" = "rgb(${palette.base10})";
      };
      ecosystem = {
        no_update_news = true;
        no_donation_nag = true;
      };
      plugin = {
        hy3 = {
          group_inset = 0;
          autotile = {
            enable = false;
          };
          tabs = {
            rounding = 3;
            border_width = 0;
            height = 22;
            padding = 0;
            render_text = true;
            text_font = builtins.elemAt config.fonts.fontconfig.defaultFonts.sansSerif 0;
            text_height = 11;
            text_padding = 8;
            text_center = true;
            "col.active" = "rgba(${palette.accentPrimary}ed)";
            "col.active.text" = "rgba(${palette.base10}ed)";
            "col.active_alt_monitor" = "rgba(${palette.base01}ed)";
            "col.active_alt_monitor.text" = "rgba(${palette.base05}ed)";
            "col.focused" = "rgba(${palette.base01}ed)";
            "col.focused.text" = "rgba(${palette.base05}ed)";
            "col.inactive" = "rgba(${palette.base10}ed)";
            "col.inactive.text" = "rgba(${palette.base05}ed)";
            "col.urgent" = "rgba(${palette.warning}ed)";
            "col.urgent.text" = "rgba(${palette.base10}ed)";
          };
        };
      };
      group = {
        focus_removed_window = true;
        insert_after_current = true;
        "col.border_active" = "rgb(${palette.accentPrimary})";
        "col.border_inactive" = "rgb(${palette.base10})";
        groupbar = {
          render_titles = false;
          gradients = false;
          "col.active" = "rgb(${palette.accentPrimary})";
          "col.inactive" = "rgb(${palette.base10})";
          text_color = "rgb(${palette.base05})";
        };
      };
      decoration = {
        rounding = 3;
        active_opacity = 0.93;
        inactive_opacity = 0.93;
        fullscreen_opacity = 1.0;
        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
          color = "rgb(1a1a1a)";
        };
        blur = {
          enabled = true;
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
      gesture = [
        "3, horizontal, workspace"
      ];
      binds = {
        workspace_back_and_forth = true;
      };
      misc = {
        mouse_move_enables_dpms = true;
        key_press_enables_dpms = true;
        force_default_wallpaper = 0;
        animate_manual_resizes = true;
        focus_on_activate = true;
        disable_hyprland_guiutils_check = true;
      };
      cursor = {
        inactive_timeout = 60;
        hide_on_key_press = true;
        persistent_warps = true;
        warp_on_change_workspace = 1;
      };
      xwayland = {
        force_zero_scaling = true;
      };
      workspace = [
        "1, monitor:$monitorC, default:true"
        "2, monitor:$monitorC"
        "3, monitor:$monitorC"
        "4, monitor:$monitorC"
        "5, monitor:$monitorC"
        "6, monitor:$monitorR, default:true"
        "7, monitor:$monitorR"
        "8, monitor:$monitorR"
        "9, monitor:$monitorL, default:true"
        "10, monitor:$monitorL"
        "11, monitor:$monitorL"
      ];
      exec-once =
        lib.optional cfg.withUWSM "uwsm finalize"
        ++ [
          "${execWrapper} kitty --class terminal-workspace"
        ];
    };
  };
}
