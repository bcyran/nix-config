{
  config,
  lib,
  ...
}: let
  inherit (config.my.colorscheme) palette;
  inherit (config.my.user) home;
  cfg = config.my.programs.noctalia;

  secondaryMonitors = builtins.listToAttrs (map (name: {
      inherit name;
      value = {
        start = [
          "control-center"
          "workspaces"
        ];
        center = [];
        end = [
          "clock"
        ];
      };
    })
    cfg.monitors.secondary);

  noctaliaColorscheme = {
    mPrimary = "#${palette.base0D}";
    mOnPrimary = "#${palette.base00}";
    mSecondary = "#${palette.base0B}";
    mOnSecondary = "#${palette.base00}";
    mTertiary = "#${palette.base0E}";
    mOnTertiary = "#${palette.base00}";
    mError = "#${palette.base0F}";
    mOnError = "#${palette.base00}";
    mSurface = "#${palette.base00}";
    mOnSurface = "#${palette.base04}";
    mSurfaceVariant = "#${palette.base10}";
    mOnSurfaceVariant = "#${palette.base03}";
    mOutline = "#${palette.base01}";
    mShadow = "#${palette.base11}";
    mHover = "#${palette.base01}";
    mOnHover = "#${palette.base05}";

    terminal = {
      background = "#${palette.base00}";
      foreground = "#${palette.base05}";
      cursor = "#${palette.base05}";
      cursorText = "#${palette.base00}";
      selectionBg = "#${palette.base02}";
      selectionFg = "#${palette.base05}";
      normal = {
        black = "#${palette.base00}";
        red = "#${palette.base08}";
        green = "#${palette.base0B}";
        yellow = "#${palette.base0A}";
        blue = "#${palette.base0D}";
        magenta = "#${palette.base0E}";
        cyan = "#${palette.base0C}";
        white = "#${palette.base05}";
      };
      bright = {
        black = "#${palette.base03}";
        red = "#${palette.base08}";
        green = "#${palette.base0B}";
        yellow = "#${palette.base0A}";
        blue = "#${palette.base0D}";
        magenta = "#${palette.base0E}";
        cyan = "#${palette.base0C}";
        white = "#${palette.base07}";
      };
    };
  };
in {
  options.my.programs.noctalia = {
    enable = lib.mkEnableOption "noctalia";

    monitors = {
      primary = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = ''
          List of primary monitor names. These monitors get the full widget
          layout and host the lock screen, notifications, and the OSD.
        '';
        example = [
          "DP-5"
          "eDP-1"
        ];
      };

      secondary = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = ''
          List of secondary monitor names. These monitors get a simplified bar
          (control center, workspaces, and clock only).
        '';
        example = [
          "DP-6"
          "DP-7"
        ];
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.noctalia = {
      enable = true;
      settings = {
        accessibility.ui_scale = 1.1;

        wallpaper = {
          enabled = true;
          directory = "${home}/Obrazy/Tapety";
          fill_mode = "crop";
          fill_color = "#${palette.base00}";
          transition = [
            "fade"
          ];
          transition_duration = 1500.0;
          edge_smoothness = 0.05;
          transition_on_startup = false;
          automation = {
            enabled = false;
            interval_seconds = 300;
            order = "random";
            recursive = true;
          };
        };

        backdrop.enabled = false;

        theme = {
          mode = "dark";
          source = "custom";
          custom_palette = "colorscheme";
          templates.enable_builtin_templates = false;
        };

        bar.order = [
          "default"
        ];

        bar.default = {
          position = "top";
          thickness = 34;
          padding = 12;
          margin_edge = 0;
          margin_ends = 0;
          widget_spacing = 16;
          font_scale = 1.11;
          font_weight = 400;
          background_opacity = 0.75;
          radius = 8;
          auto_hide = false;
          show_on_workspace_switch = true;
          reserve_space = true;
          layer = "top";
          shadow = true;
          capsule = false;
          hover_highlight = true;

          start = [
            "control-center"
            "workspaces"
            "active-window"
          ];
          center = [];
          end = [
            "lock-keys"
            "privacy"
            "media"
            "audio-visualizer"
            "tray"
            "volume"
            "brightness"
            "caffeine"
            "network"
            "bluetooth"
            "sysmon-cpu-usage"
            "sysmon-cpu-temp"
            "sysmon-ram"
            "battery"
            "notifications"
            "clock"
          ];

          actions = {
            right = "panel-toggle control-center";
            middle = "none";
            scroll_up = "none";
            scroll_down = "none";
          };

          monitor = secondaryMonitors;
        };

        widget = {
          "control-center".type = "control-center";

          workspaces = {
            type = "workspaces";
            label_source = "name";
            labels_only_when_occupied = true;
            show_icons = true;
            pill_scale = 1.0;
            scale = 1.15;
            focused_color = "primary";
            empty_color = "outline";
            occupied_color = "outline";
            urgent_color = "secondary";
            focused_output_only = true;
            font_weight = 700;
          };

          active-window = {
            type = "active_window";
            display = "text_only";
            max_length = 800;
            min_length = 80;
            title_scroll = "on_hover";
            show_empty_label = false;
          };

          lock-keys = {
            type = "lock_keys";
            display = "short";
            show_caps_lock = true;
            show_num_lock = true;
            show_scroll_lock = true;
            hide_when_off = true;
          };

          privacy = {
            type = "privacy";
            hide_inactive = true;
            icon_spacing = 4;
            active_color = "primary";
          };

          media = {
            type = "media";
            artist_first = true;
            hide_album_art = false;
            max_length = 300;
            title_scroll = "on_hover";
            hide_when_no_media = true;
            art_size = 32;
            show_progress = true;
            scroll_repeat = "gesture";
            actions.middle = "media toggle";
          };

          audio-visualizer = {
            type = "audio_visualizer";
            width = 56;
            bands = 16;
            mirrored = false;
            show_when_idle = false;
            color_1 = "primary";
            color_2 = "primary";
          };

          tray = {
            type = "tray";
            hidden = [];
            pinned = [];
            hide_passive = false;
            drawer = true;
            drawer_columns = 3;
          };

          volume = {
            type = "volume";
            device = "output";
            show_label = false;
            actions.middle = "exec pwvucontrol || pavucontrol";
          };

          brightness = {
            type = "brightness";
            show_label = false;
          };

          caffeine.type = "caffeine";

          network = {
            type = "network";
            show_label = false;
            vpn_status = "both";
          };

          bluetooth = {
            type = "bluetooth";
            show_label = false;
            hide_when_adapter_off = true;
          };

          sysmon-cpu-usage = {
            type = "sysmon";
            stat = "cpu_usage";
            visualization = "gauge";
            show_value = true;
            show_glyph = true;
          };

          sysmon-cpu-temp = {
            type = "sysmon";
            stat = "cpu_temp";
            visualization = "gauge";
            show_value = true;
            show_glyph = true;
          };

          sysmon-ram = {
            type = "sysmon";
            stat = "ram_used";
            visualization = "gauge";
            show_value = true;
            show_glyph = true;
          };

          battery = {
            type = "battery";
            display_mode = "graphic";
            show_label = true;
            label_content = "percent";
            device = "auto";
            hide_when_plugged = false;
            hide_when_full = true;
          };

          notifications = {
            type = "notifications";
            hide_when_no_unread = false;
          };

          clock = {
            type = "clock";
            format = "{:%a %-d %B %H:%M}";
            tooltip_format = "{:%a %-d %B %H:%M}";
            vertical_format = "%H\n%M";
            font_family = "Inter";
            font_weight = 600;
          };
        };

        system.monitor = {
          enabled = true;
          cpu_usage_activity_threshold = 80;
          cpu_usage_critical_threshold = 90;
          cpu_temp_activity_threshold = 80;
          cpu_temp_critical_threshold = 90;
          ram_pct_activity_threshold = 80;
          ram_pct_critical_threshold = 90;
          disk_used_pct_activity_threshold = 80;
          disk_used_pct_critical_threshold = 90;
        };

        battery.warning_threshold = 20;

        brightness = {
          enable_ddcutil = true;
          minimum_brightness = 0.1;
          sync_all_monitors = true;
        };

        audio = {
          enable_overdrive = false;
          enable_sounds = false;
          sound_volume = 0.5;
        };

        shell = {
          font_family = "Inter";
          avatar_path = "${home}/.face.jpg";
          telemetry_enabled = false;
          polkit_agent = true;
          time_format = "%H\n%M";
          date_format = "%A, %-d %B %Y";
          clipboard_enabled = true;
          clipboard_auto_paste = "off";
          corner_radius_scale = 1.0;
          button_borders = false;
          input_borders = false;
          popup_borders = false;
          card_borders = false;
          popup_shadows = true;
          setup_wizard_enabled = false;
          show_location = true;
          animation = {
            enabled = true;
            speed = 2.0;
          };
          shadow = {
            direction = "down_right";
            alpha = 0.55;
          };
          screen_corners = {
            enabled = true;
            size = 24;
          };
          privacy = {
            mic_filter_regex = "";
            cam_filter_regex = "";
            screen_filter_regex = "";
          };
          launcher = {
            categories = false;
            show_icons = true;
            sort_by_usage = true;
            pinned = [];
            app_grid = false;
            provider_prefix = "/";
            providers.session.global = true;
            auto_paste = "off";
            fetch_exchange_rates = true;
          };
          panel = {
            transparency_mode = "glass";
            borders = false;
            shadow = true;
            list_item_background = false;
            floating_offset = 8;
            launcher_placement = "floating";
            launcher_position = "center";
            clipboard_placement = "floating";
            clipboard_position = "center";
            control_center_placement = "attached";
            open_near_click_control_center = true;
            wallpaper_placement = "attached";
            session_placement = "floating";
            session_position = "center";
            polkit_placement = "floating";
            polkit_position = "center";
          };
          screenshot = {
            annotate = true;
            directory = "${home}/Obrazy/Screenshots";
          };
          session = {
            show_shortcuts = true;
            actions = [
              {
                action = "lock";
                shortcut = "1";
                countdown_seconds = 0.0;
                enabled = true;
                variant = "default";
              }
              {
                action = "logout";
                shortcut = "2";
                countdown_seconds = 10.0;
                enabled = true;
                variant = "default";
              }
              {
                action = "lock_and_suspend";
                shortcut = "3";
                countdown_seconds = 10.0;
                enabled = true;
                variant = "default";
              }
              {
                action = "hibernate";
                command = "systemctl hibernate";
                shortcut = "4";
                countdown_seconds = 10.0;
                enabled = true;
                variant = "default";
              }
              {
                action = "reboot";
                shortcut = "5";
                countdown_seconds = 10.0;
                enabled = true;
                variant = "default";
              }
              {
                action = "shutdown";
                shortcut = "6";
                countdown_seconds = 10.0;
                enabled = true;
                variant = "destructive";
              }
            ];
          };
        };

        keybinds = {
          up = [
            "Up"
            "Ctrl+P"
          ];
          down = [
            "Down"
            "Ctrl+N"
          ];
          left = [
            "Left"
            "Ctrl+H"
          ];
          right = [
            "Right"
            "Ctrl+L"
          ];
          validate = [
            "Return"
            "space"
          ];
          cancel = [
            "Escape"
          ];
          delete = [
            "Delete"
          ];
        };

        notification = {
          enable_daemon = true;
          position = "top_right";
          layer = "overlay";
          background_opacity = 1.0;
          keep_dismissed_in_history = true;
          show_actions = true;
          show_app_name = true;
          monitors = cfg.monitors.primary;
        };

        osd = {
          enabled = true;
          position = "top_right";
          position_vertical = "top_center";
          background_opacity = 1.0;
          monitors = cfg.monitors.primary;
          kinds = {
            media = false;
            keyboard_layout = true;
          };
        };

        lockscreen = {
          enabled = true;
          lock_before_suspend = true;
          monitors = cfg.monitors.primary;
          blur_intensity = 0.0;
          tint_intensity = 0.0;
          allow_empty_password = false;
          fingerprint = true;
        };

        location = {
          address = "Wroclaw, Poland";
          auto_locate = false;
          # Set through the control center: the fixed sunrise/sunset pair is
          # ignored, so nightlight follows the real sun.
          custom_schedule = false;
          sunrise = "06:30";
          sunset = "18:30";
        };

        # Action set through the control center, feature left off.
        hot_corners = {
          enabled = false;
          top_left.action = "launcher";
        };

        weather = {
          enabled = true;
          effects = true;
          unit = "metric";
          refresh_minutes = 30;
        };

        calendar = {
          enabled = true;
          account.home_nextcloud = {
            provider = "custom";
            server_url = "https://nextcloud.intra.cyran.dev/remote.php/dav/";
            type = "caldav";
            username = "bazyli";
          };
        };

        control_center = {
          sidebar = "full";
          width = 700;
          show_shortcut_labels = true;
          show_session_button = true;
          hidden_tabs = [];
          calendar = {
            show_events_card = true;
            show_week_numbers = false;
          };
          shortcuts = [
            {
              type = "power_profile";
            }
            {
              type = "nightlight";
            }
            {
              type = "notification";
            }
            {
              type = "wallpaper";
            }
            {
              type = "noctalia/screen_recorder:toggle";
            }
          ];
        };

        nightlight = {
          enabled = true;
          force = false;
          temperature_day = 6500;
          temperature_night = 4000;
        };

        dock = {
          enabled = false;
          position = "bottom";
          auto_hide = true;
          background_opacity = 0.8;
          icon_size = 48;
          inactive_opacity = 1.0;
          magnification = true;
          magnification_scale = 1.4;
          show_dots = true;
          show_running = true;
          show_instance_count = true;
          launcher_position = "none";
          active_monitor_only = false;
          monitors = [];
          pinned = [
            "firefox"
            "kitty"
            "thunar"
            "joplin"
            "signal"
            "spotify"
            "org.keepassxc.KeePassXC"
          ];
        };

        idle = {
          pre_action_fade_seconds = 5.0;
          behavior_order = [
            "lock"
            "screen-off"
            "lock-and-suspend"
          ];
          behavior = {
            lock = {
              action = "lock";
              enabled = true;
              timeout = 660.0;
            };
            screen-off = {
              action = "screen_off";
              enabled = true;
              timeout = 600.0;
            };
            lock-and-suspend = {
              action = "lock_and_suspend";
              enabled = false;
            };
          };
        };

        plugins = {
          enabled = [
            "noctalia/screen_recorder"
            "noctalia/translator"
          ];
          source = [
            {
              name = "official";
              kind = "git";
              location = "https://github.com/noctalia-dev/official-plugins";
              enabled = true;
            }
          ];
        };
      };

      customPalettes.colorscheme.dark = noctaliaColorscheme;
    };
  };
}
