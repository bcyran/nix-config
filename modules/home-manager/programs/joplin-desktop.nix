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
  ];
in {
  options.my.programs.joplin-desktop.enable = lib.mkEnableOption "joplin-desktop";

  config = lib.mkIf cfg.enable {
    programs.joplin-desktop = {
      enable = true;
      general.editor = lib.getExe pkgs.neovim;
      sync = {
        target = "joplin-server";
        interval = "5m";
      };

      extraConfig = let
        inherit (config.fonts.fontconfig) defaultFonts;
        editorFont = builtins.elemAt defaultFonts.monospace 0;
      in {
        "editor.codeView" = true;
        "sync.9.path" = "https://joplin.${my.lib.const.domains.intra}";
        "sync.9.username" = config.my.user.email;
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
              width = 210;
              visible = true;
            }
            {
              key = "noteList";
              width = 220;
              visible = true;
            }
            {
              key = "editor";
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
        });
      }
      // my.lib.mapListToAttrs mkPluginFile plugins;
  };
}
