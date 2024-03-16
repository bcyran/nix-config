{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    sensibleOnTop = true;
    escapeTime = 100;
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
      set -g mode-style "fg=#82aaff,bg=#3b4261"
      set -g message-style "fg=#82aaff,bg=#3b4261"
      set -g message-command-style "fg=#82aaff,bg=#3b4261"
      set -g pane-border-style "fg=#3b4261"
      set -g pane-active-border-style "fg=#82aaff"
      set -g status "on"
      set -g status-justify "left"
      set -g status-style "fg=#82aaff,bg=#1e2030"
      set -g status-left-length "100"
      set -g status-right-length "100"
      set -g status-left-style NONE
      set -g status-right-style NONE
      set -g status-left "#[fg=#1b1d2b,bg=#82aaff,bold] #S #[fg=#82aaff,bg=#1e2030,nobold,nounderscore,noitalics]"
      set -g status-right "#[fg=#1e2030,bg=#1e2030,nobold,nounderscore,noitalics]#[fg=#82aaff,bg=#1e2030] #{prefix_highlight} #[fg=#3b4261,bg=#1e2030,nobold,nounderscore,noitalics]#[fg=#82aaff,bg=#3b4261] %Y-%m-%d  %I:%M %p #[fg=#82aaff,bg=#3b4261,nobold,nounderscore,noitalics]#[fg=#1b1d2b,bg=#82aaff,bold] #h "
      if-shell '[ "$(tmux show-option -gqv "clock-mode-style")" == "24" ]' {
        set -g status-right "#[fg=#1e2030,bg=#1e2030,nobold,nounderscore,noitalics]#[fg=#82aaff,bg=#1e2030] #{prefix_highlight} #[fg=#3b4261,bg=#1e2030,nobold,nounderscore,noitalics]#[fg=#82aaff,bg=#3b4261] %Y-%m-%d  %H:%M #[fg=#82aaff,bg=#3b4261,nobold,nounderscore,noitalics]#[fg=#1b1d2b,bg=#82aaff,bold] #h "
      }
      setw -g window-status-activity-style "underscore,fg=#828bb8,bg=#1e2030"
      setw -g window-status-separator ""
      setw -g window-status-style "NONE,fg=#828bb8,bg=#1e2030"
      setw -g window-status-format "#[fg=#1e2030,bg=#1e2030,nobold,nounderscore,noitalics]#[default] #I  #W #F #[fg=#1e2030,bg=#1e2030,nobold,nounderscore,noitalics]"
      setw -g window-status-current-format "#[fg=#1e2030,bg=#3b4261,nobold,nounderscore,noitalics]#[fg=#82aaff,bg=#3b4261,bold] #I  #W #F #[fg=#3b4261,bg=#1e2030,nobold,nounderscore,noitalics]"
    '';
  };
}
