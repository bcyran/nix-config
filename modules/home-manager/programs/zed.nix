{
  config,
  lib,
  pkgs,
  my,
  ...
}: let
  cfg = config.my.programs.zed;
in {
  options.my.programs.zed.enable = lib.mkEnableOption "zed";

  config = lib.mkIf cfg.enable {
    programs.zed-editor = {
      enable = true;
      extensions = [
        "tokyo-night"
        "nix"
        "html"
        "dockerfile"
        "log"
        "scss"
        "dart"
        "ruff"
        "codebook"
        "basedpyright"
        "python-refactoring"
        "just"
        "helm"
        "catppuccin"
        "plantuml"
      ];

      extraPackages = with pkgs; [
        nil
        nixd
        alejandra
      ];

      userKeymaps = [
        {
          context = "Editor && (vim_mode == normal || vim_mode == visual) && !VimWaiting && !menu";
          bindings = {
            "space g h d" = "editor::ToggleHunkDiff";
            "space g h r" = "editor::RevertSelectedHunks";
            "space t i" = "editor::ToggleInlayHints";
            "space u w" = "editor::ToggleSoftWrap";
            "space c z" = "workspace::ToggleCenteredLayout";
            "space m p" = "markdown::OpenPreview";
            "space m P" = "markdown::OpenPreviewToTheSide";
            "space f p" = "projects::OpenRecent";
            "space s w" = "pane::DeploySearch";
            "space a c" = "assistant::ToggleFocus";
            "g f" = "editor::OpenExcerpts";
            "space e" = "workspace::ToggleLeftDock";
            "space f f" = "file_finder::Toggle";
            "shift-k" = "editor::Hover";
            "space b d" = "pane::CloseActiveItem";
            "ctrl-w" = "pane::CloseActiveItem";
            "space g b" = "editor::ToggleGitBlame";
            "space /" = "workspace::NewSearch";
            "space l f" = "editor::Format";
            "space d" = "diagnostics::Deploy";
            "space o" = "tab_switcher::Toggle";
            "n" = "search::SelectNextMatch";
            "shift-n" = "search::SelectPrevMatch";
            "g b" = "editor::ToggleComments";
            "space c r" = "editor::Rename";
            "space g d" = "editor::GoToDefinition";
            "space g i" = "editor::GoToImplementation";
            "g r" = "editor::FindAllReferences";
          };
        }
        {
          context = "Pane";
          bindings = {
            "space v" = "pane::SplitRight";
            "space h" = "pane::SplitDown";
          };
        }
        {
          context = "Dock || Terminal || Editor";
          bindings = {
            "ctrl-h" = ["workspace::ActivatePaneInDirection" "Left"];
            "ctrl-l" = ["workspace::ActivatePaneInDirection" "Right"];
            "ctrl-k" = ["workspace::ActivatePaneInDirection" "Up"];
            "ctrl-j" = ["workspace::ActivatePaneInDirection" "Down"];
          };
        }
        {
          bindings = {
            "ctrl-shift-tab" = "pane::ActivatePrevItem";
            "ctrl-tab" = "pane::ActivateNextItem";
          };
        }
        {
          context = "Terminal";
          bindings = {
            "ctrl-w" = "pane::CloseActiveItem"; # Don't pass ctrl-w to terminal; let Zed handle it.
            "ctrl-`" = "workspace::ToggleBottomDock"; # match vscode behavior
          };
        }
      ];

      userSettings = {
        ssh_connections = [
          {
            host = my.lib.const.lan.devices.atlas.domain;
            projects = [
              {paths = [config.my.user.configDir];}
            ];
          }
        ];
        telemetry = {
          diagnostics = false;
          metrics = false;
        };
        vim_mode = true;
        load_direnv = "shell_hook";
        ui_font_size = 16;
        buffer_font_size = 17;
        buffer_font_family = builtins.elemAt config.fonts.fontconfig.defaultFonts.monospace 0;
        format_on_save = "on";
        relative_line_numbers = true;
        vertical_scroll_margin = 10;
        indent_guides = {
          enabled = true;
        };
        file_scan_exclusions = [
          "**/.git"
          "**/.svn"
          "**/.hg"
          "**/CVS"
          "**/.DS_Store"
          "**/Thumbs.db"
          "**/.classpath"
          "**/.settings"
          "**/node_modules"
          "**/target"
        ];
        theme = {
          mode = "dark";
          light = "Tokyo Night Storm";
          dark = "Tokyo Night Storm";
        };
        languages = {
          Python = {
            format_on_save = {
              language_server = {
                name = "ruff";
              };
            };
            formatter = {
              language_server = {
                name = "ruff";
              };
            };
            language_servers = ["pyright" "ruff"];
          };
          Nix = {
            language_servers = ["!nil" "nixd"];
            tab_size = 2;
            formatter = {
              external = {
                command = "alejandra";
                arguments = ["--quiet" "--"];
              };
            };
          };
        };
        lsp = {
          rust-analyzer = {
            binary = {
              path = lib.getExe pkgs.rust-analyzer;
            };
          };
          nix = {
            binary = {
              path_lookup = lib.getExe pkgs.nix;
            };
          };
          nil = {
            binary = {
              path = lib.getExe pkgs.nil;
            };
            initialization_options = {
              formatting = {
                command = ["alejandra" "--quiet" "--"];
              };
            };
          };
          nixd = {
            binary = {
              path = lib.getExe pkgs.nixd;
            };
          };
          pyright = {
            settings = {
              python.analysis = {
                typeCheckingMode = "on";
                reportMissingImports = false;
                reportMissingTypeStubs = false;
              };
              python = {
                pythonPath = ".venv/bin/python";
              };
            };
            disableOrganizeImports = true;
          };
        };
      };
    };
  };
}
