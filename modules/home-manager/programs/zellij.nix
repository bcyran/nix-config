{
  config,
  lib,
  ...
}: let
  inherit (config.colorscheme) palette;
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

    home.sessionVariables = lib.mkIf cfg.enableShellIntegration {
      ZELLIJ_AUTO_ATTACH = "true";
      ZELLIJ_AUTO_EXIT = "true";
    };

    xdg.configFile."zellij/config.kdl".text = ''
      keybinds clear-defaults=true {
        normal {
          bind "Alt h" { MoveFocusOrTab "Left"; }
          bind "Alt l" { MoveFocusOrTab "Right"; }
          bind "Alt j" { MoveFocus "Down"; }
          bind "Alt k" { MoveFocus "Up"; }

          bind "Alt H" { Resize "Increase Left"; }
          bind "Alt L" { Resize "Increase Right"; }
          bind "Alt J" { Resize "Increase Down"; }
          bind "Alt K" { Resize "Increase Up"; }

          bind "Alt Tab" "Ctrl Tab" { ToggleTab; }
        }
        tmux  {
          bind "Ctrl a" "Esc" { Write 2; SwitchToMode "Normal"; }

          bind "c" { NewTab; SwitchToMode "Normal"; }
          bind "n" { GoToNextTab; SwitchToMode "Normal"; }
          bind "p" { GoToPreviousTab; SwitchToMode "Normal"; }
          bind "," { SwitchToMode "RenameTab"; TabNameInput 0; }
          bind "Tab" { ToggleTab; SwitchToMode "Normal"; }

          bind "|" { NewPane  "Right"; SwitchToMode "Normal"; }
          bind "-" { NewPane  "Down"; SwitchToMode "Normal"; }
          bind "." { SwitchToMode "RenamePane"; PaneNameInput 0; }
          bind "z" { ToggleFocusFullscreen; SwitchToMode "Normal"; }

          bind "h" { MoveFocusOrTab "Left"; SwitchToMode "Normal"; }
          bind "l" { MoveFocusOrTab "Right"; SwitchToMode "Normal"; }
          bind "j" { MoveFocus "Down"; SwitchToMode "Normal"; }
          bind "k" { MoveFocus "Up"; SwitchToMode "Normal"; }

          bind "v" { SwitchToMode "Scroll"; }
          bind "Space" { NextSwapLayout; }
          bind "x" { CloseFocus; SwitchToMode "Normal"; }

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
          bind "e" { EditScrollback; SwitchToMode "Normal"; }
          bind "s" { SwitchToMode "EnterSearch"; SearchInput 0; }
          bind "Ctrl c" { ScrollToBottom; SwitchToMode "Normal"; }

          bind "j" { ScrollDown; }
          bind "k" { ScrollUp; }
          bind "Ctrl f" { PageScrollDown; }
          bind "Ctrl b" { PageScrollUp; }
          bind "Ctrl d" { HalfPageScrollDown; }
          bind "Ctrl u" { HalfPageScrollUp; }
        }
        entersearch {
          bind "Esc" "Ctrl c" { ScrollToBottom; SwitchToMode "Scroll"; }
          bind "Enter" { SwitchToMode "Search"; }
        }
        search {
          bind "Esc" "Ctrl c" { ScrollToBottom; SwitchToMode "Scroll"; }

          bind "j" { ScrollDown; }
          bind "k" { ScrollUp; }
          bind "Ctrl f" { PageScrollDown; }
          bind "Ctrl b" { PageScrollUp; }
          bind "Ctrl d" { HalfPageScrollDown; }
          bind "Ctrl u" { HalfPageScrollUp; }

          bind "n" { Search "down"; }
          bind "p" { Search "up"; }

          bind "c" { SearchToggleOption "CaseSensitivity"; }
          bind "w" { SearchToggleOption "Wrap"; }
          bind "o" { SearchToggleOption "WholeWord"; }
        }
        shared_except "tmux" "locked" {
          bind "Ctrl a" "Alt a" { SwitchToMode "Tmux"; }
        }
        shared_except "normal" {
          bind "Esc" { Write 2; SwitchToMode "Normal"; }
        }
      }

      themes {
        custom {
          bg "#${palette.base00}"
          black "#${palette.base00}"
          blue "#${palette.base0D}"
          cyan "#${palette.base0C}"
          fg "#${palette.base05}"
          green "#${palette.base0B}"
          magenta "#${palette.base0E}"
          orange "#${palette.base09}"
          red "#${palette.base08}"
          white "#${palette.base05}"
          yellow "#${palette.base0A}"
        }
      }
      theme "custom"
    '';
  };
}
