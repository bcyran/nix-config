{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    sensibleOnTop = true;
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
      tmuxPlugins.onedark-theme
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
    '';
  };
}
