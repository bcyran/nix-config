{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  inherit (config.colorScheme) palette;
  cfg = config.my.programs.tmux;
in {
  options.my.programs.tmux.enable = mkEnableOption "tmux";

  config = mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      sensibleOnTop = true;
      escapeTime = 50;
      terminal = "tmux-256color";
      keyMode = "vi";
      shortcut = "a";
      mouse = true;
      baseIndex = 1;
      clock24 = true;
      historyLimit = 10000;
      customPaneNavigationAndResize = true;
      plugins = with pkgs; [
        tmuxPlugins.vim-tmux-navigator
      ];
      extraConfig = ''
        set -ag terminal-overrides ",xterm-256color:RGB"

        unbind r
        bind r source-file ~/.config/tmux/tmux.conf

        set-window-option -g mode-keys vi
        bind-key -T copy-mode-vi 'v' send -X begin-selection
        bind-key -T copy-mode-vi 'y' send -X copy-selection-and-cancel
        unbind -T copy-mode-vi MouseDragEnd1Pane

        unbind %
        bind | split-window -h
        unbind '"'
        bind - split-window -v

        bind -r j resize-pane -D 5
        bind -r k resize-pane -U 5
        bind -r l resize-pane -R 5
        bind -r h resize-pane -L 5
        bind -r m resize-pane -Z

        # Tokyo Night moon theme
        # https://github.com/folke/tokyonight.nvim/blob/main/extras/tmux/tokyonight_moon.tmux
        set -g mode-style "fg=#${palette.base0D},bg=#${palette.base01}"
        set -g message-style "fg=#${palette.base0D},bg=#${palette.base01}"
        set -g message-command-style "fg=#${palette.base0D},bg=#${palette.base01}"
        set -g pane-border-style "fg=#${palette.base01}"
        set -g pane-active-border-style "fg=#${palette.base0D}"
        set -g status "on"
        set -g status-justify "left"
        set -g status-style "fg=#${palette.base0D},bg=#${palette.base10}"
        set -g status-left-length "100"
        set -g status-right-length "100"
        set -g status-left-style NONE
        set -g status-right-style NONE
        set -g status-left "#[fg=#${palette.base11},bg=#${palette.base0D},bold] #S #[fg=#${palette.base0D},bg=#${palette.base10},nobold,nounderscore,noitalics]"
        set -g status-right "#[fg=#${palette.base10},bg=#${palette.base10},nobold,nounderscore,noitalics]#[fg=#${palette.base0D},bg=#${palette.base10}] #{prefix_highlight} #[fg=#${palette.base01},bg=#${palette.base10},nobold,nounderscore,noitalics]#[fg=#${palette.base0D},bg=#${palette.base01}] %Y-%m-%d  %I:%M %p #[fg=#${palette.base0D},bg=#${palette.base01},nobold,nounderscore,noitalics]#[fg=#${palette.base11},bg=#${palette.base0D},bold] #h "
        if-shell '[ "$(tmux show-option -gqv "clock-mode-style")" == "24" ]' {
          set -g status-right "#[fg=#${palette.base10},bg=#${palette.base10},nobold,nounderscore,noitalics]#[fg=#${palette.base0D},bg=#${palette.base10}] #{prefix_highlight} #[fg=#${palette.base01},bg=#${palette.base10},nobold,nounderscore,noitalics]#[fg=#${palette.base0D},bg=#${palette.base01}] %Y-%m-%d  %H:%M #[fg=#${palette.base0D},bg=#${palette.base01},nobold,nounderscore,noitalics]#[fg=#${palette.base11},bg=#${palette.base0D},bold] #h "
        }
        setw -g window-status-activity-style "underscore,fg=#${palette.base04},bg=#${palette.base10}"
        setw -g window-status-separator ""
        setw -g window-status-style "NONE,fg=#${palette.base04},bg=#${palette.base10}"
        setw -g window-status-format "#[fg=#${palette.base10},bg=#${palette.base10},nobold,nounderscore,noitalics]#[default] #I  #W #F #[fg=#${palette.base10},bg=#${palette.base10},nobold,nounderscore,noitalics]"
        setw -g window-status-current-format "#[fg=#${palette.base10},bg=#${palette.base01},nobold,nounderscore,noitalics]#[fg=#${palette.base0D},bg=#${palette.base01},bold] #I  #W #F #[fg=#${palette.base01},bg=#${palette.base10},nobold,nounderscore,noitalics]"
      '';
    };
  };
}
