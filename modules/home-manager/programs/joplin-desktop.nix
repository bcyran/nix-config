{
  my,
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.my.programs.joplin-desktop;
  jsonFormat = pkgs.formats.json {};
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

    xdg.configFile."joplin-desktop/keymap-desktop.json".source = let
      mkKeymapsList = lib.mapAttrsToList (command: accelerator: {
        inherit command accelerator;
      });
    in
      jsonFormat.generate "keymap-desktop.json" (mkKeymapsList {
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
  };
}
