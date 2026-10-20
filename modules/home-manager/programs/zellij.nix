{
  config,
  lib,
  ...
}: let
  inherit (config.my.colorscheme) palette;
  cfg = config.my.programs.zellij;
in {
  options.my.programs.zellij = {
    enable = lib.mkEnableOption "zellij";
    enableShellIntegration = lib.mkEnableOption "zellij auto start on shell startup";
  };

  config = lib.mkIf cfg.enable {
    programs.zellij = {
      enable = true;
      enableFishIntegration = cfg.enableShellIntegration;
      enableZshIntegration = cfg.enableShellIntegration;
      enableBashIntegration = cfg.enableShellIntegration;
    };

    xdg.configFile."zellij/config.kdl".text = ''
      show_startup_tips false
      show_release_notes false

      keybinds clear-defaults=true {
        normal {
          // Navigation
          bind "Alt h" { MoveFocusOrTab "Left"; }
          bind "Alt l" { MoveFocusOrTab "Right"; }
          bind "Alt j" { MoveFocus "Down"; }
          bind "Alt k" { MoveFocus "Up"; }

          // Resize
          bind "Alt H" { Resize "Increase Left"; }
          bind "Alt L" { Resize "Increase Right"; }
          bind "Alt J" { Resize "Increase Down"; }
          bind "Alt K" { Resize "Increase Up"; }

          // Quick actions
          bind "Alt Tab" "Ctrl Tab" { ToggleTab; }
          bind "Alt f" { ToggleFloatingPanes; }
          bind "Alt n" { NewPane; }
          bind "Alt u" { Resize "Increase"; }
          bind "Alt i" { Resize "Decrease"; }

          // Pane grouping
          bind "Alt g" { TogglePaneInGroup; };
          bind "Alt G" { ToggleGroupMarking; };

          // Tab movement
          bind "Alt o" { GoToPreviousTab; SwitchToMode "Normal"; }
          bind "Alt p" { GoToNextTab; SwitchToMode "Normal"; }
          bind "Alt O" { MoveTab "Left"; }
          bind "Alt P" { MoveTab "Right"; }
        }

        tmux  {
          bind "Ctrl a" "Esc" { Write 2; SwitchToMode "Normal"; }

          // Tabs
          bind "c" { NewTab; SwitchToMode "Normal"; }
          bind "o" { GoToPreviousTab; SwitchToMode "Normal"; }
          bind "p" { GoToNextTab; SwitchToMode "Normal"; }
          bind "," { SwitchToMode "RenameTab"; TabNameInput 0; }
          bind "Tab" { ToggleTab; SwitchToMode "Normal"; }

          // Direct tab access
          bind "1" { GoToTab 1; SwitchToMode "Normal"; }
          bind "2" { GoToTab 2; SwitchToMode "Normal"; }
          bind "3" { GoToTab 3; SwitchToMode "Normal"; }
          bind "4" { GoToTab 4; SwitchToMode "Normal"; }
          bind "5" { GoToTab 5; SwitchToMode "Normal"; }
          bind "6" { GoToTab 6; SwitchToMode "Normal"; }
          bind "7" { GoToTab 7; SwitchToMode "Normal"; }
          bind "8" { GoToTab 8; SwitchToMode "Normal"; }
          bind "9" { GoToTab 9; SwitchToMode "Normal"; }

          // Panes
          bind "|" { NewPane  "Right"; SwitchToMode "Normal"; }
          bind "v" { NewPane  "Right"; SwitchToMode "Normal"; }
          bind "-" { NewPane  "Down"; SwitchToMode "Normal"; }
          bind "h" { NewPane  "Down"; SwitchToMode "Normal"; }
          bind "." { SwitchToMode "RenamePane"; PaneNameInput 0; }
          bind "z" { ToggleFocusFullscreen; SwitchToMode "Normal"; }
          bind "x" { CloseFocus; SwitchToMode "Normal"; }
          bind "f" { ToggleFloatingPanes; SwitchToMode "Normal"; }
          bind "w" { TogglePaneFrames; SwitchToMode "Normal"; }
          bind "e" { TogglePaneEmbedOrFloating; SwitchToMode "Normal"; }
          bind "g" { TogglePaneInGroup; SwitchToMode "Normal"; }
          bind "G" { ToggleGroupMarking; SwitchToMode "Normal"; }

          // Navigation
          bind "H" { MoveFocusOrTab "Left"; SwitchToMode "Normal"; }
          bind "L" { MoveFocusOrTab "Right"; SwitchToMode "Normal"; }
          bind "J" { MoveFocus "Down"; SwitchToMode "Normal"; }
          bind "K" { MoveFocus "Up"; SwitchToMode "Normal"; }

          // Mode switches
          bind "a" { SwitchToMode "Scroll"; }
          bind "m" { SwitchToMode "Move"; }
          bind "r" { SwitchToMode "Resize"; }
          bind "u" { SwitchToMode "Session"; }

          // Layouts
          bind "Space" { NextSwapLayout; }
          bind "b" { PreviousSwapLayout; }

          bind "d" { Detach; }
          bind "Ctrl q" { Quit; }
        }

        renametab {
          bind "Ctrl a" "Enter" { SwitchToMode "Normal"; }
          bind "Esc" { UndoRenameTab; SwitchToMode "Normal"; }
        }

        renamepane {
          bind "Ctrl a" "Enter" { SwitchToMode "Normal"; }
          bind "Esc" { UndoRenamePane; SwitchToMode "Pane"; }
        }

        scroll {
          bind "Esc" "Ctrl a" "q" { ScrollToBottom; SwitchToMode "Normal"; }

          bind "e" { EditScrollback; SwitchToMode "Normal"; }
          bind "s" { SwitchToMode "EnterSearch"; SearchInput 0; }

          // Vim-style navigation
          bind "j" "Down" { ScrollDown; }
          bind "k" "Up" { ScrollUp; }
          bind "f" "Ctrl f" { PageScrollDown; }
          bind "b" "Ctrl b" { PageScrollUp; }
          bind "d" "Ctrl d" { HalfPageScrollDown; }
          bind "u" "Ctrl u" { HalfPageScrollUp; }
          bind "g" { ScrollToTop; }
          bind "G" { ScrollToBottom; }
        }

        entersearch {
          bind "Esc" "Ctrl c" "Ctrl a" { ScrollToBottom; SwitchToMode "Scroll"; }
          bind "Enter" { SwitchToMode "Search"; }
        }

        search {
          bind "Esc" "Ctrl a" "q" { ScrollToBottom; SwitchToMode "Normal"; }

          // Vim-style navigation
          bind "j" "Down" { ScrollDown; }
          bind "k" "Up" { ScrollUp; }
          bind "f" "Ctrl f" { PageScrollDown; }
          bind "b" "Ctrl b" { PageScrollUp; }
          bind "d" "Ctrl d" { HalfPageScrollDown; }
          bind "u" "Ctrl u" { HalfPageScrollUp; }
          bind "g" { ScrollToTop; }
          bind "G" { ScrollToBottom; }

          // Search navigation
          bind "n" { Search "down"; }
          bind "N" { Search "up"; }

          // Search options
          bind "c" { SearchToggleOption "CaseSensitivity"; }
          bind "w" { SearchToggleOption "Wrap"; }
          bind "o" { SearchToggleOption "WholeWord"; }
        }

        resize {
          bind "Esc" "Enter" "Ctrl a" { SwitchToMode "Normal"; }

          // Basic resize
          bind "h" { Resize "Increase Left"; }
          bind "j" { Resize "Increase Down"; }
          bind "k" { Resize "Increase Up"; }
          bind "l" { Resize "Increase Right"; }

          // Shift for decrease
          bind "H" { Resize "Decrease Left"; }
          bind "J" { Resize "Decrease Down"; }
          bind "K" { Resize "Decrease Up"; }
          bind "L" { Resize "Decrease Right"; }

          bind "u" { Resize "Increase"; }
          bind "i" { Resize "Decrease"; }
        }

        move {
          bind "Esc" "Enter" "Ctrl a" { SwitchToMode "Normal"; }

          bind "n" "Tab" { MovePane; }
          bind "p" { MovePaneBackwards; }
          bind "h" { MovePane "Left"; }
          bind "j" { MovePane "Down"; }
          bind "k" { MovePane "Up"; }
          bind "l" { MovePane "Right"; }
        }

        session {
          bind "Esc" "Enter" "Ctrl a" { SwitchToMode "Normal"; }

          bind "d" { Detach; }
          bind "w" {
            LaunchOrFocusPlugin "session-manager" {
              floating true
              move_to_focused_tab true
            };
            SwitchToMode "Normal"
          }
          bind "c" {
            LaunchOrFocusPlugin "configuration" {
              floating true
              move_to_focused_tab true
            };
            SwitchToMode "Normal"
          }
          bind "p" {
            LaunchOrFocusPlugin "plugin-manager" {
              floating true
              move_to_focused_tab true
            };
            SwitchToMode "Normal"
          }
        }

        shared_except "tmux" "locked" {
          bind "Ctrl a" "Alt a" { SwitchToMode "Tmux"; }
        }

        shared_except "locked" {
          bind "Ctrl g" { SwitchToMode "Locked"; }
        }

        shared_except "normal" "locked" {
          bind "Esc" { SwitchToMode "Normal"; }
        }

        locked {
            bind "Ctrl g" { SwitchToMode "Normal"; }
        }
      }

      themes {
        custom {
          text_unselected {
            base "#${palette.base05}"
            background "#${palette.base01}"
            emphasis_0 "#${palette.base0A}"
            emphasis_1 "#${palette.base0C}"
            emphasis_2 "#${palette.base0D}"
            emphasis_3 "#${palette.base0E}"
          }
          text_selected {
            base "#${palette.base05}"
            background "#${palette.base00}"
            emphasis_0 "#${palette.base0A}"
            emphasis_1 "#${palette.base0C}"
            emphasis_2 "#${palette.base0D}"
            emphasis_3 "#${palette.base0E}"
          }
          ribbon_selected {
            base "#${palette.base01}"
            background "#${palette.base0D}"
            emphasis_0 "#${palette.base0C}"
            emphasis_1 "#${palette.base09}"
            emphasis_2 "#${palette.base0E}"
            emphasis_3 "#${palette.base0D}"
          }
          ribbon_unselected {
            base "#${palette.base01}"
            background "#${palette.base04}"
            emphasis_0 "#${palette.base0C}"
            emphasis_1 "#${palette.base05}"
            emphasis_2 "#${palette.base0D}"
            emphasis_3 "#${palette.base0E}"
          }
          table_title {
            base "#${palette.base0D}"
            background "#${palette.base00}"
            emphasis_0 "#${palette.base0A}"
            emphasis_1 "#${palette.base0C}"
            emphasis_2 "#${palette.base0D}"
            emphasis_3 "#${palette.base0E}"
          }
          table_cell_selected {
            base "#${palette.base05}"
            background "#${palette.base00}"
            emphasis_0 "#${palette.base0A}"
            emphasis_1 "#${palette.base0C}"
            emphasis_2 "#${palette.base0D}"
            emphasis_3 "#${palette.base0E}"
          }
          table_cell_unselected {
            base "#${palette.base05}"
            background "#${palette.base01}"
            emphasis_0 "#${palette.base0A}"
            emphasis_1 "#${palette.base0C}"
            emphasis_2 "#${palette.base0D}"
            emphasis_3 "#${palette.base0E}"
          }
          list_selected {
            base "#${palette.base05}"
            background "#${palette.base00}"
            emphasis_0 "#${palette.base0A}"
            emphasis_1 "#${palette.base0C}"
            emphasis_2 "#${palette.base0D}"
            emphasis_3 "#${palette.base0E}"
          }
          list_unselected {
            base "#${palette.base05}"
            background "#${palette.base01}"
            emphasis_0 "#${palette.base0A}"
            emphasis_1 "#${palette.base0C}"
            emphasis_2 "#${palette.base0D}"
            emphasis_3 "#${palette.base0E}"
          }
          frame_selected {
            base "#${palette.base0D}"
            background "#${palette.base00}"
            emphasis_0 "#${palette.base0A}"
            emphasis_1 "#${palette.base0C}"
            emphasis_2 "#${palette.base0E}"
            emphasis_3 "#${palette.base00}"
          }
          frame_highlight {
            base "#${palette.base0A}"
            background "#${palette.base00}"
            emphasis_0 "#${palette.base0E}"
            emphasis_1 "#${palette.base0A}"
            emphasis_2 "#${palette.base0A}"
            emphasis_3 "#${palette.base0A}"
          }
          exit_code_success {
            base "#${palette.base0D}"
            background "#${palette.base00}"
            emphasis_0 "#${palette.base0C}"
            emphasis_1 "#${palette.base01}"
            emphasis_2 "#${palette.base0E}"
            emphasis_3 "#${palette.base0D}"
          }
          exit_code_error {
            base "#${palette.base08}"
            background "#${palette.base00}"
            emphasis_0 "#${palette.base0A}"
            emphasis_1 "#${palette.base00}"
            emphasis_2 "#${palette.base00}"
            emphasis_3 "#${palette.base00}"
          }
          multiplayer_user_colors {
            player_1 "#${palette.base0E}"
            player_2 "#${palette.base0D}"
            player_3 "#${palette.base00}"
            player_4 "#${palette.base0A}"
            player_5 "#${palette.base0C}"
            player_6 "#${palette.base00}"
            player_7 "#${palette.base08}"
            player_8 "#${palette.base00}"
            player_9 "#${palette.base00}"
            player_10 "#${palette.base00}"
          }
        }
      }
      theme "custom"
    '';
  };
}
