{
  config,
  lib,
  ...
}: let
  inherit (config.colorScheme) palette;
  cfg = config.my.programs.noctalia;

  # Widget configuration for primary monitors (full feature set)
  primaryWidgets = {
    left = [
      {
        characterCount = 2;
        colorizeIcons = false;
        emptyColor = "secondary";
        enableScrollWheel = true;
        focusedColor = "primary";
        followFocusedScreen = false;
        fontWeight = "bold";
        groupedBorderOpacity = 1;
        hideUnoccupied = false;
        iconScale = 0.8;
        id = "Workspace";
        labelMode = "name";
        occupiedColor = "none";
        pillSize = 0.7;
        showApplications = true;
        showApplicationsHover = false;
        showBadge = true;
        showLabelsOnlyWhenOccupied = true;
        unfocusedIconsOpacity = 1;
      }
      {
        colorizeIcons = false;
        hideMode = "hidden";
        id = "ActiveWindow";
        maxWidth = 300;
        scrollingMode = "hover";
        showIcon = false;
        showText = true;
        textColor = "none";
        useFixedWidth = false;
      }
    ];
    center = [
      {
        clockColor = "none";
        customFont = "";
        formatHorizontal = "HH:mm, d MMMM";
        formatVertical = "HH mm";
        id = "Clock";
        tooltipFormat = "HH:mm ddd, MMM dd";
        useCustomFont = false;
        useMonospacedFont = false;
        usePrimaryColor = true;
      }
    ];
    right = [
      {
        compactMode = false;
        hideMode = "idle";
        hideWhenIdle = false;
        id = "MediaMini";
        maxWidth = 300;
        panelShowAlbumArt = true;
        scrollingMode = "hover";
        showAlbumArt = true;
        showArtistFirst = true;
        showProgressRing = true;
        showVisualizer = true;
        textColor = "none";
        useFixedWidth = false;
        visualizerType = "linear";
      }
      {
        applyToAllMonitors = false;
        displayMode = "alwaysShow";
        iconColor = "none";
        id = "Brightness";
        textColor = "none";
      }
      {
        displayMode = "alwaysShow";
        iconColor = "none";
        id = "Volume";
        middleClickCommand = "pwvucontrol || pavucontrol";
        textColor = "none";
      }
      {
        displayMode = "onhover";
        iconColor = "none";
        id = "Network";
        textColor = "none";
      }
      {
        displayMode = "onhover";
        iconColor = "none";
        id = "VPN";
        textColor = "none";
      }
      {
        displayMode = "onhover";
        iconColor = "none";
        id = "Bluetooth";
        textColor = "none";
      }
      {
        alwaysShowPercentage = false;
        deviceNativePath = "__default__";
        displayMode = "graphic";
        hideIfIdle = false;
        hideIfNotDetected = true;
        id = "Battery";
        showNoctaliaPerformance = false;
        showPowerProfiles = false;
        warningThreshold = 30;
      }
      {
        blacklist = [];
        chevronColor = "none";
        colorizeIcons = false;
        drawerEnabled = true;
        hidePassive = false;
        id = "Tray";
        pinned = [];
      }
      {
        hideWhenZero = false;
        hideWhenZeroUnread = false;
        iconColor = "none";
        id = "NotificationHistory";
        showUnreadBadge = true;
        unreadBadgeColor = "primary";
      }
      {
        id = "ControlCenter";
        useDistroLogo = true;
      }
    ];
  };

  # Widget configuration for secondary monitors (simplified)
  secondaryWidgets = {
    left = [
      {
        characterCount = 2;
        colorizeIcons = false;
        emptyColor = "none";
        enableScrollWheel = true;
        focusedColor = "primary";
        followFocusedScreen = false;
        fontWeight = "bold";
        groupedBorderOpacity = 1;
        hideUnoccupied = false;
        iconScale = 0.8;
        id = "Workspace";
        labelMode = "name";
        occupiedColor = "none";
        pillSize = 0.7;
        showApplications = true;
        showApplicationsHover = false;
        showBadge = true;
        showLabelsOnlyWhenOccupied = true;
        unfocusedIconsOpacity = 1;
      }
    ];
    center = [
      {
        formatHorizontal = "HH:mm";
        formatVertical = "HH mm";
        id = "Clock";
        useMonospacedFont = false;
        usePrimaryColor = true;
      }
    ];
    right = [
      {
        id = "ControlCenter";
        useDistroLogo = true;
      }
    ];
  };

  # Generate list of all monitors
  allMonitors = cfg.monitors.primary ++ cfg.monitors.secondary;

  # Generate screen overrides for secondary monitors
  screenOverrides =
    map (monitorName: {
      displayMode = "always_visible";
      enabled = true;
      name = monitorName;
      widgets = secondaryWidgets;
    })
    cfg.monitors.secondary;
in {
  options.my.programs.noctalia = {
    enable = lib.mkEnableOption "noctalia";

    monitors = {
      primary = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = ["eDP-1"];
        description = ''
          List of primary monitor names. These monitors will have the full widget set
          including media controls, system tray, and all status indicators.
          All primary monitors will be used for notifications, OSD, and lock screen.
        '';
        example = ["DP-5" "eDP-1"];
      };

      secondary = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = ''
          List of secondary monitor names. These monitors will have simplified widgets
          (workspace indicator, clock, and control center only).
        '';
        example = ["DP-6" "DP-7"];
      };

      ddcMappings = lib.mkOption {
        type = lib.types.listOf (lib.types.attrsOf lib.types.str);
        default = [];
        description = ''
          DDC/CI brightness device mappings for external monitors.
          Each mapping specifies which backlight device controls which output.
        '';
        example = [
          {
            device = "/sys/class/backlight/ddcci14";
            output = "DP-5";
          }
          {
            device = "/sys/class/backlight/ddcci15";
            output = "DP-6";
          }
        ];
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.noctalia-shell = {
      enable = true;
      colors = {
        mError = "#${palette.error}";
        mOnError = "#${palette.base00}";
        mOnPrimary = "#${palette.base00}";
        mOnSecondary = "#${palette.base00}";
        mOnSurface = "#${palette.base04}";
        mOnSurfaceVariant = "#${palette.base03}";
        mOnTertiary = "#${palette.base00}";
        mOnHover = "#${palette.base05}";
        mOutline = "#${palette.base01}";
        mPrimary = "#${palette.base0D}";
        mSecondary = "#${palette.base0B}";
        mShadow = "#${palette.base11}";
        mSurface = "#${palette.base00}";
        mHover = "#${palette.base01}";
        mSurfaceVariant = "#${palette.base10}";
        mTertiary = "#${palette.base0E}";
      };
      settings = {
        settingsVersion = 59;
        bar = {
          barType = "simple";
          position = "top";
          monitors = allMonitors;
          density = "comfortable";
          showOutline = false;
          showCapsule = false;
          capsuleOpacity = 1;
          capsuleColorKey = "none";
          widgetSpacing = 6;
          contentPadding = 2;
          fontScale = 1.1099999999999999;
          enableExclusionZoneInset = true;
          backgroundOpacity = 0.93;
          useSeparateOpacity = false;
          marginVertical = 4;
          marginHorizontal = 4;
          frameThickness = 8;
          frameRadius = 12;
          outerCorners = false;
          hideOnOverview = false;
          displayMode = "always_visible";
          autoHideDelay = 500;
          autoShowDelay = 150;
          showOnWorkspaceSwitch = true;
          widgets = primaryWidgets;
          mouseWheelAction = "none";
          reverseScroll = false;
          mouseWheelWrap = true;
          middleClickAction = "none";
          middleClickFollowMouse = false;
          middleClickCommand = "";
          rightClickAction = "controlCenter";
          rightClickFollowMouse = true;
          rightClickCommand = "";
          inherit screenOverrides;
        };
        general = {
          avatarImage = "${config.my.user.home}/.face.jpg";
          dimmerOpacity = 0.2;
          showScreenCorners = true;
          forceBlackScreenCorners = true;
          scaleRatio = 1.1;
          radiusRatio = 1;
          iRadiusRatio = 1;
          boxRadiusRatio = 1;
          screenRadiusRatio = 0.3;
          animationSpeed = 2;
          animationDisabled = false;
          compactLockScreen = false;
          lockScreenAnimations = true;
          lockOnSuspend = true;
          showSessionButtonsOnLockScreen = true;
          showHibernateOnLockScreen = false;
          enableLockScreenMediaControls = true;
          enableShadows = true;
          enableBlurBehind = true;
          shadowDirection = "bottom_right";
          shadowOffsetX = 2;
          shadowOffsetY = 3;
          language = "";
          allowPanelsOnScreenWithoutBar = true;
          showChangelogOnStartup = true;
          telemetryEnabled = false;
          enableLockScreenCountdown = true;
          lockScreenCountdownDuration = 10000;
          autoStartAuth = false;
          allowPasswordWithFprintd = false;
          clockStyle = "digital";
          clockFormat = "hh\\nmm";
          passwordChars = false;
          lockScreenMonitors = cfg.monitors.primary;
          lockScreenBlur = 0;
          lockScreenTint = 0;
          keybinds = {
            keyUp = [
              "Up"
              "Ctrl+P"
            ];
            keyDown = [
              "Down"
              "Ctrl+N"
            ];
            keyLeft = [
              "Left"
              "Ctrl+H"
            ];
            keyRight = [
              "Right"
              "Ctrl+L"
            ];
            keyEnter = [
              "Return"
              "Enter"
            ];
            keyEscape = [
              "Esc"
            ];
            keyRemove = [
              "Del"
            ];
          };
          reverseScroll = false;
          smoothScrollEnabled = true;
        };
        ui = {
          fontDefault = "Inter";
          fontFixed = "JetBrainsMono NF";
          fontDefaultScale = 1;
          fontFixedScale = 1;
          tooltipsEnabled = true;
          scrollbarAlwaysVisible = true;
          boxBorderEnabled = false;
          panelBackgroundOpacity = 0.93;
          translucentWidgets = false;
          panelsAttachedToBar = true;
          settingsPanelMode = "window";
          settingsPanelSideBarCardStyle = false;
        };
        location = {
          name = "Wroclaw, Poland";
          weatherEnabled = true;
          weatherShowEffects = true;
          weatherTaliaMascotAlways = false;
          useFahrenheit = false;
          use12hourFormat = false;
          showWeekNumberInCalendar = false;
          showCalendarEvents = true;
          showCalendarWeather = true;
          analogClockInCalendar = false;
          firstDayOfWeek = -1;
          hideWeatherTimezone = false;
          hideWeatherCityName = false;
          autoLocate = false;
        };
        calendar = {
          cards = [
            {
              enabled = true;
              id = "calendar-header-card";
            }
            {
              enabled = true;
              id = "calendar-month-card";
            }
            {
              enabled = true;
              id = "weather-card";
            }
          ];
        };
        wallpaper = {
          enabled = true;
          overviewEnabled = false;
          directory = "${config.my.user.home}/Obrazy/Tapety";
          monitorDirectories = [];
          enableMultiMonitorDirectories = false;
          showHiddenFiles = false;
          viewMode = "browse";
          setWallpaperOnAllMonitors = true;
          linkLightAndDarkWallpapers = true;
          fillMode = "crop";
          fillColor = "#${palette.base00}";
          useSolidColor = false;
          solidColor = "#1a1a2e";
          automationEnabled = false;
          wallpaperChangeMode = "random";
          randomIntervalSec = 300;
          transitionDuration = 1500;
          transitionType = [
            "wipe"
          ];
          skipStartupTransition = false;
          transitionEdgeSmoothness = 0.05;
          panelPosition = "follow_bar";
          hideWallpaperFilenames = false;
          useOriginalImages = false;
          overviewBlur = 0.4;
          overviewTint = 0.6;
          useWallhaven = false;
          wallhavenQuery = "";
          wallhavenSorting = "relevance";
          wallhavenOrder = "desc";
          wallhavenCategories = "111";
          wallhavenPurity = "100";
          wallhavenRatios = "";
          wallhavenApiKey = "";
          wallhavenResolutionMode = "atleast";
          wallhavenResolutionWidth = "";
          wallhavenResolutionHeight = "";
          sortOrder = "date_desc";
          favorites = [];
        };
        appLauncher = {
          enableClipboardHistory = true;
          autoPasteClipboard = false;
          enableClipPreview = true;
          clipboardWrapText = true;
          enableClipboardSmartIcons = true;
          enableClipboardChips = true;
          clipboardWatchTextCommand = "wl-paste --type text --watch cliphist store";
          clipboardWatchImageCommand = "wl-paste --type image --watch cliphist store";
          position = "center";
          pinnedApps = [];
          sortByMostUsed = true;
          terminalCommand = "kitty";
          customLaunchPrefixEnabled = false;
          customLaunchPrefix = "";
          viewMode = "list";
          showCategories = true;
          iconMode = "tabler";
          showIconBackground = false;
          enableSettingsSearch = true;
          enableWindowsSearch = true;
          enableSessionSearch = true;
          ignoreMouseInput = false;
          screenshotAnnotationTool = "";
          overviewLayer = false;
          density = "default";
        };
        controlCenter = {
          position = "top_right";
          diskPath = "/";
          shortcuts = {
            left = [
              {
                id = "KeepAwake";
              }
              {
                id = "NightLight";
              }
              {
                id = "WallpaperSelector";
              }
            ];
            right = [
              {
                id = "AirplaneMode";
              }
              {
                id = "PowerProfile";
              }
              {
                id = "NoctaliaPerformance";
              }
            ];
          };
          cards = [
            {
              enabled = true;
              id = "profile-card";
            }
            {
              enabled = true;
              id = "shortcuts-card";
            }
            {
              enabled = true;
              id = "audio-card";
            }
            {
              enabled = true;
              id = "brightness-card";
            }
            {
              enabled = true;
              id = "weather-card";
            }
            {
              enabled = true;
              id = "media-sysmon-card";
            }
          ];
        };
        systemMonitor = {
          cpuWarningThreshold = 80;
          cpuCriticalThreshold = 90;
          tempWarningThreshold = 80;
          tempCriticalThreshold = 90;
          gpuWarningThreshold = 80;
          gpuCriticalThreshold = 90;
          memWarningThreshold = 80;
          memCriticalThreshold = 90;
          swapWarningThreshold = 80;
          swapCriticalThreshold = 90;
          diskWarningThreshold = 80;
          diskCriticalThreshold = 90;
          diskAvailWarningThreshold = 20;
          diskAvailCriticalThreshold = 10;
          batteryWarningThreshold = 20;
          batteryCriticalThreshold = 5;
          enableDgpuMonitoring = false;
          useCustomColors = false;
          warningColor = "";
          criticalColor = "";
          externalMonitor = "resources || missioncenter || jdsystemmonitor || corestats || system-monitoring-center || gnome-system-monitor || plasma-systemmonitor || mate-system-monitor || ukui-system-monitor || deepin-system-monitor || pantheon-system-monitor";
        };
        noctaliaPerformance = {
          disableWallpaper = true;
          disableDesktopWidgets = true;
        };
        dock = {
          enabled = false;
          position = "bottom";
          displayMode = "auto_hide";
          dockType = "floating";
          backgroundOpacity = 1;
          floatingRatio = 1;
          size = 1;
          onlySameOutput = true;
          monitors = [];
          pinnedApps = [];
          colorizeIcons = false;
          showLauncherIcon = false;
          launcherPosition = "end";
          launcherUseDistroLogo = false;
          launcherIcon = "";
          launcherIconColor = "none";
          pinnedStatic = false;
          inactiveIndicators = false;
          groupApps = false;
          groupContextMenuMode = "extended";
          groupClickAction = "cycle";
          groupIndicatorStyle = "dots";
          deadOpacity = 0.6;
          animationSpeed = 1;
          sitOnFrame = false;
          showDockIndicator = false;
          indicatorThickness = 3;
          indicatorColor = "primary";
          indicatorOpacity = 0.6;
        };
        network = {
          bluetoothRssiPollingEnabled = false;
          bluetoothRssiPollIntervalMs = 60000;
          networkPanelView = "wifi";
          wifiDetailsViewMode = "grid";
          bluetoothDetailsViewMode = "grid";
          bluetoothHideUnnamedDevices = false;
          disableDiscoverability = false;
          bluetoothAutoConnect = true;
        };
        sessionMenu = {
          enableCountdown = true;
          countdownDuration = 10000;
          position = "center";
          showHeader = true;
          showKeybinds = true;
          largeButtonsStyle = true;
          largeButtonsLayout = "single-row";
          powerOptions = [
            {
              action = "lock";
              command = "";
              countdownEnabled = false;
              enabled = true;
              keybind = "1";
            }
            {
              action = "suspend";
              command = "";
              countdownEnabled = true;
              enabled = true;
              keybind = "2";
            }
            {
              action = "hibernate";
              command = "";
              countdownEnabled = true;
              enabled = true;
              keybind = "3";
            }
            {
              action = "reboot";
              command = "";
              countdownEnabled = true;
              enabled = true;
              keybind = "4";
            }
            {
              action = "logout";
              command = "";
              countdownEnabled = true;
              enabled = true;
              keybind = "5";
            }
            {
              action = "shutdown";
              command = "";
              countdownEnabled = true;
              enabled = true;
              keybind = "6";
            }
            {
              action = "rebootToUefi";
              command = "";
              countdownEnabled = true;
              enabled = true;
              keybind = "7";
            }
            {
              action = "userspaceReboot";
              command = "";
              countdownEnabled = true;
              enabled = false;
              keybind = "";
            }
          ];
        };
        notifications = {
          enabled = true;
          enableMarkdown = false;
          density = "default";
          monitors = cfg.monitors.primary;
          location = "top_right";
          overlayLayer = true;
          backgroundOpacity = 1;
          respectExpireTimeout = false;
          lowUrgencyDuration = 3;
          normalUrgencyDuration = 8;
          criticalUrgencyDuration = 15;
          clearDismissed = true;
          saveToHistory = {
            low = true;
            normal = true;
            critical = true;
          };
          sounds = {
            enabled = false;
            volume = 0.5;
            separateSounds = false;
            criticalSoundFile = "";
            normalSoundFile = "";
            lowSoundFile = "";
            excludedApps = "discord,firefox,chrome,chromium,edge";
          };
          enableMediaToast = false;
          enableKeyboardLayoutToast = true;
          enableBatteryToast = true;
        };
        osd = {
          enabled = true;
          location = "top_right";
          autoHideMs = 2000;
          overlayLayer = true;
          backgroundOpacity = 1;
          enabledTypes = [
            0
            1
            2
          ];
          monitors = cfg.monitors.primary;
        };
        audio = {
          volumeStep = 5;
          volumeOverdrive = false;
          spectrumFrameRate = 30;
          visualizerType = "linear";
          spectrumMirrored = true;
          mprisBlacklist = [];
          preferredPlayer = "";
          volumeFeedback = false;
          volumeFeedbackSoundFile = "";
        };
        brightness = {
          brightnessStep = 5;
          enforceMinimum = true;
          enableDdcSupport = false;
          backlightDeviceMappings = cfg.monitors.ddcMappings;
        };
        colorSchemes = {
          useWallpaperColors = false;
          predefinedScheme = "Tokyo Night Moon";
          darkMode = true;
          schedulingMode = "off";
          manualSunrise = "06:30";
          manualSunset = "18:30";
          generationMethod = "faithful";
          monitorForColors = "";
          syncGsettings = true;
        };
        templates = {
          activeTemplates = [];
          enableUserTheming = false;
        };
        nightLight = {
          enabled = true;
          forced = false;
          autoSchedule = true;
          nightTemp = "4000";
          dayTemp = "6500";
          manualSunrise = "06:30";
          manualSunset = "18:30";
        };
        hooks = {
          enabled = false;
          wallpaperChange = "";
          darkModeChange = "";
          screenLock = "";
          screenUnlock = "";
          performanceModeEnabled = "";
          performanceModeDisabled = "";
          startup = "";
          session = "";
          colorGeneration = "";
        };
        plugins = {
          autoUpdate = false;
          notifyUpdates = true;
        };
        idle = {
          enabled = true;
          screenOffTimeout = 600;
          lockTimeout = 660;
          suspendTimeout = 0;
          fadeDuration = 5;
          screenOffCommand = "";
          lockCommand = "";
          suspendCommand = "";
          resumeScreenOffCommand = "";
          resumeLockCommand = "";
          resumeSuspendCommand = "";
          customCommands = "[]";
        };
        desktopWidgets = {
          enabled = false;
          overviewEnabled = true;
          gridSnap = false;
          gridSnapScale = false;
          monitorWidgets = [];
        };
      };
    };
  };
}
