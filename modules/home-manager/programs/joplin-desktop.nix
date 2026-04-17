{
  my,
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.my.programs.joplin-desktop;
  jsonFormat = pkgs.formats.json {};

  plugins = [
    "com.ckant.joplin-plugin-better-code-blocks.jpl"
    "com.github.alan-null.joplin-plugin-github-alerts.jpl"
    "com.joplin.copy.codeBlocks.jpl"
    "com.joplin.excalidraw.jpl"
    "com.whatever.inline-tags.jpl"
    "com.whatever.quick-links.jpl"
    "io.github.personalizedrefrigerator.codemirror6-settings.jpl"
    "joplin.plugin.benji.quick-move.jpl"
    "net.rmusin.joplin-table-formatter.jpl"
    "org.joplinapp.plugins.ToggleSidebars.jpl"
    "plugin.calebjohn.MathMode.jpl"
    "plugin.calebjohn.rich-markdown.jpl"
    "joplin.plugin.note.tabs.jpl"
    "org.joplinapp.plugins.admonition.jpl"
  ];
in {
  options.my.programs.joplin-desktop = {
    enable = lib.mkEnableOption "joplin-desktop";
    sync = {
      enable = lib.mkEnableOption "Joplin sync" // {default = true;};
      path = lib.mkOption {
        type = lib.types.str;
        default = "https://joplin.${my.lib.const.domains.intra}";
        description = "Joplin sync server URL.";
      };
      username = lib.mkOption {
        type = lib.types.str;
        default = config.my.user.email;
        description = "Username for Joplin sync server.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.joplin-desktop = {
      enable = true;
      general.editor = lib.getExe pkgs.neovim;
      sync = lib.mkIf cfg.sync.enable {
        target = "joplin-server";
        interval = "5m";
      };

      extraConfig = let
        inherit (config.fonts.fontconfig) defaultFonts;
        editorFont = builtins.elemAt defaultFonts.monospace 0;
      in
        {
          "editor.codeView" = true;
          locale = "pl_PL";
          dateFormat = "DD.MM.YYYY";
          "ocr.enabled" = true;
          theme = 2;
          themeAutoDetect = false;
          layoutButtonSequence = 1;
          "notes.sortOrder.field" = "user_updated_time";
          "notes.sortOrder.reverse" = true;
          "notes.perFieldReverse" = {
            user_updated_time = true;
            user_created_time = true;
            title = false;
            order = false;
            todo_due = true;
            todo_completed = true;
          };
          newTodoFocus = "title";
          "notes.listRendererId" = "compact";
          "markdown.plugin.softbreaks" = true;
          "markdown.plugin.typographer" = true;
          "markdown.plugin.sub" = true;
          "markdown.plugin.sup" = true;
          "markdown.plugin.multitable" = true;
          showTrayIcon = false;
          "style.editor.fontSize" = 15;
          "style.editor.fontFamily" = editorFont;
          "style.editor.monospaceFontFamily" = editorFont;
          "ui.layout" = {
            key = "root";
            children = [
              {
                key = "sideBar";
                visible = true;
                width = 210;
              }
              {
                key = "noteList";
                visible = true;
                width = 220;
              }
              {
                key = "tempContainer-LesXc856pKyjJUTaxYr7gP";
                children = [
                  {
                    key = "plugin-view-joplin.plugin.note.tabs-note.tabs.panel";
                    context = {
                      pluginId = "joplin.plugin.note.tabs";
                    };
                    visible = true;
                    height = 40;
                  }
                  {
                    key = "editor";
                    visible = true;
                  }
                ];
                visible = true;
              }
            ];
            visible = true;
          };
          "clipperServer.autoStart" = true;
          noteVisiblePanes = ["viewer"];
          "editor.keyboardMode" = "vim";
          "editor.spellCheckBeta" = true;
          "spellChecker.languages" = ["en-US" "pl"];
          windowContentZoomFactor = 110;
        }
        // lib.optionalAttrs cfg.sync.enable {
          "sync.9.path" = cfg.sync.path;
          "sync.9.username" = cfg.sync.username;
        };
    };

    xdg.configFile = let
      mkKeymapsList = lib.mapAttrsToList (command: accelerator: {
        inherit command accelerator;
      });
      mkPluginFile = plugin: {
        name = "joplin-desktop/plugins/${plugin}";
        value = {source = "${my.pkgs.joplin-plugins}/${plugin}";};
      };
    in
      {
        "joplin-desktop/keymap-desktop.json".source = jsonFormat.generate "keymap-desktop.json" (mkKeymapsList {
          newNote = "Ctrl+Shift+N";
          newTodo = null;
          insertDateTime = null;
          focusSearch = "Ctrl+Shift+F";
          focusElementSideBar = "Ctrl+Shift+L";
          focusElementNoteList = "Ctrl+L";
          focusElementNoteTitle = "Ctrl+T";
          focusElementNoteBody = "Ctrl+N";
          toggleVisiblePanes = "Ctrl+E";
          toggleExternalEditing = null;
          setTags = "Ctrl+Shift+T";
          "editor.richMarkdown.clickAtCursor" = "Ctrl+Enter";
          "richMarkdown.inlineImages" = null;
          "richMarkdown.focusMode" = null;
          CreateBackup = null;
          "tabsSwitchLastActive" = "Ctrl+Tab";
        });
      }
      // my.lib.mapListToAttrs mkPluginFile plugins;
  };
}
