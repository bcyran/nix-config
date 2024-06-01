{pkgs, ...}: {
  programs.fish = {
    enable = true;
    shellAbbrs = {
      g = "git";
    };
    shellAliases = {
      git = "LANG=en_US.UTF-8 command git";
      k = "kubectl";
      ls = "eza --icons";
      la = "ls --all";
      ll = "ls --all --long --classify";
      tree = "eza --tree";
      vim = "nvim";
    };
    functions = {
      fish_title = ''
        set -q argv[1]; or set argv fish
        echo $USER@(hostname) (prompt_pwd): $argv[1]
      '';
      fish_user_key_bindings = ''
        for mode in insert default visual
            bind -M $mode \cp history-search-backward
            bind -M $mode \cn history-search-forward
            bind -M $mode \cy accept-autosuggestion
        end
      '';
      cat = ''
        if isatty && type bat > /dev/null
          bat $argv
        else
          command cat $argv
        end
      '';
      up = ''
        set -l counter $argv[1]

        if test -z $counter
            set counter 1
        end

        if ! string match -rq '^[0-9]+$' $counter
            echo "Usage: up [NUMBER]"
            return 1
        end

        set nwd (pwd)
        while test $counter -ge 1
            set nwd (dirname $nwd)
            set counter (math $counter - 1)
        end
        cd $nwd || return 1
      '';
      extract = ''
        if ! test -f $argv[1]
            echo "$argv[1] is not a valid file"
            return 1
        end

        switch $argv[1]
            case '''
                echo 'Usage: extract [FILE]'
                return 1
            case '*.tar.bz2'
                tar xvjf $argv[1]
            case '*.tar.gz'
                tar xvzf $argv[1]
            case '*.tar.xz'
                tar xvJf $argv[1]
            case '*.bz2'
                bunzip2 $argv[1]
            case '*.rar'
                unrar x $argv[1]
            case '*.gz'
                gunzip $argv[1]
            case '*.tar'
                tar xvf $argv[1]
            case '*.tbz2'
                tar xvjf $argv[1]
            case '*.tgz'
                tar xvzf $argv[1]
            case '*.zip'
                unzip $argv[1]
            case '*.Z'
                uncompress $argv[1]
            case '*.7z'
                7z x $argv[1]
            case *
                echo "Unable to extract $argv[1]: unsupported format."
                return 1
        end
      '';
    };
    interactiveShellInit = ''
      fish_vi_key_bindings
      set -gx fish_vi_force_cursor
      set -gx fish_greeting
      set -gx fish_cursor_default block
      set -gx fish_cursor_insert line
      set -gx fish_cursor_replace_one underscore
      set -gx fish_cursor_visual block

      set -gx tide_right_prompt_items status cmd_duration context jobs node python rustc java go

      # TokyoNight Color Palette
      # https://github.com/folke/tokyonight.nvim/blob/main/extras/fish/tokyonight_moon.fish
      set -l foreground c8d3f5
      set -l selection 2d3f76
      set -l comment 636da6
      set -l red ff757f
      set -l orange ff966c
      set -l yellow ffc777
      set -l green c3e88d
      set -l purple fca7ea
      set -l cyan 86e1fc
      set -l pink c099ff

      # Syntax Highlighting Colors
      set -g fish_color_normal $foreground
      set -g fish_color_command $cyan
      set -g fish_color_keyword $pink
      set -g fish_color_quote $yellow
      set -g fish_color_redirection $foreground
      set -g fish_color_end $orange
      set -g fish_color_error $red
      set -g fish_color_param $purple
      set -g fish_color_comment $comment
      set -g fish_color_selection --background=$selection
      set -g fish_color_search_match --background=$selection
      set -g fish_color_operator $green
      set -g fish_color_escape $pink
      set -g fish_color_autosuggestion $comment

      # Completion Pager Colors
      set -g fish_pager_color_progress $comment
      set -g fish_pager_color_prefix $cyan
      set -g fish_pager_color_completion $foreground
      set -g fish_pager_color_description $comment
      set -g fish_pager_color_selected_background --background=$selection
    '';
    plugins = [
      {
        name = "tide";
        src = pkgs.fishPlugins.tide.src;
      }
      {
        name = "autopair";
        src = pkgs.fishPlugins.autopair.src;
      }
    ];
  };
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };
}
