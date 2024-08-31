{
  config,
  lib,
  ...
}: let
  inherit (config.colorScheme) palette;
  cfg = config.my.programs.fzf;
in {
  options.my.programs.fzf.enable = lib.mkEnableOption "fzf";

  config = let
    fdCommonArgs = "--follow --exclude .git --exclude node_modules --exclude target";
  in
    lib.mkIf cfg.enable {
      programs.fzf = {
        enable = true;
        colors = {
          bg = "#${palette.base00}";
          fg = "#${palette.base05}";
          "bg+" = "#${palette.base02}";
          "fg+" = "#${palette.base05}";
          preview-bg = "#${palette.base00}";
          preview-fg = "#${palette.base05}";
          hl = "#${palette.base0D}";
          "hl+" = "#${palette.base0D}";
          info = "#${palette.base03}";
          border = "#${palette.base0D}";
          prompt = "#${palette.base0E}";
          pointer = "#${palette.base09}";
          spinner = "#${palette.base0E}";
          marker = "#${palette.base0B}";
          header = "#${palette.base03}";
        };
        defaultOptions = [
          "--height 100%"
          "--border"
        ];
        changeDirWidgetCommand = "fd --type d ${fdCommonArgs}";
        changeDirWidgetOptions = [
          "--preview 'eza --color=always --tree {}' | head -n 200"
        ];
        fileWidgetCommand = "fd --type f ${fdCommonArgs}";
        fileWidgetOptions = [
          "--preview 'bat -n --color=always {}'"
          "--bind 'ctrl-/:change-preview-window(down|hidden|)'"
        ];
        historyWidgetOptions = [
          "--bind 'ctrl-y:execute-silent(echo -n {2..} | wl-copy)+abort'"
          "--color header:italic"
          "--header 'Press CTRL-Y to copy command into clipboard'"
        ];
      };
    };
}
