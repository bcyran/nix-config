{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (config.colorScheme) palette;
  cfg = config.my.programs.fish;
in {
  options.my.programs.fish.enable = lib.mkEnableOption "fish";

  config = lib.mkIf cfg.enable {
    programs = {
      fish = {
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
          set -gx ATUIN_NOBIND true
          atuin init fish | source
          bind / _atuin_search

          fish_vi_key_bindings
          set -gx fish_vi_force_cursor
          set -gx fish_greeting
          set -gx fish_cursor_default block
          set -gx fish_cursor_insert line
          set -gx fish_cursor_replace_one underscore
          set -gx fish_cursor_visual block

          set -gx tide_right_prompt_items status cmd_duration context jobs node python rustc java go nix_shell direnv

          # Syntax Highlighting Colors
          set -g fish_color_normal ${palette.base05}
          set -g fish_color_command ${palette.base0D}
          set -g fish_color_keyword ${palette.base0E}
          set -g fish_color_quote ${palette.base0B}
          set -g fish_color_redirection ${palette.base0C}
          set -g fish_color_end ${palette.base0C}
          set -g fish_color_error ${palette.base0F}
          set -g fish_color_param ${palette.base05}
          set -g fish_color_comment ${palette.base03}
          set -g fish_color_selection --background=${palette.base02}
          set -g fish_color_search_match --background=${palette.base02}
          set -g fish_color_operator ${palette.base0C}
          set -g fish_color_escape ${palette.base0C}
          set -g fish_color_autosuggestion ${palette.base03}

          # Completion Pager Colors
          set -g fish_pager_color_progress ${palette.base03}
          set -g fish_pager_color_prefix ${palette.base0C}
          set -g fish_pager_color_completion ${palette.base05}
          set -g fish_pager_color_description ${palette.base03}
          set -g fish_pager_color_selected_background --background=${palette.base02}
        '';
        plugins = [
          {
            name = "tide";
            inherit (pkgs.fishPlugins.tide) src;
          }
          {
            name = "autopair";
            inherit (pkgs.fishPlugins.autopair) src;
          }
        ];
      };
      zoxide = {
        enable = true;
        enableFishIntegration = true;
      };
      atuin = {
        enable = true;
        enableBashIntegration = false;
        enableFishIntegration = false;
        enableNushellIntegration = false;
        enableZshIntegration = false;
        settings = {
          inline_height = 15;
          ctrl_n_shortcuts = true;
          enter_accept = true;
        };
      };
    };
  };
}
