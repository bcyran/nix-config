{
  pkgs,
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.programs.git;

  # NOTE: Would be nice to find a way to derive this from base16 theme colors
  deltaThemeName = config.colorScheme.slug;
  deltaTheme = pkgs.writeText "${deltaThemeName}.gitconfig" ''
    [delta "${deltaThemeName}"]
      minus-style                   = syntax "#3a273a"
      minus-non-emph-style          = syntax "#3a273a"
      minus-emph-style              = syntax "#6b2e43"
      minus-empty-line-marker-style = syntax "#3a273a"
      line-numbers-minus-style      = "#e26a75"
      plus-style                    = syntax "#273849"
      plus-non-emph-style           = syntax "#273849"
      plus-emph-style               = syntax "#305f6f"
      plus-empty-line-marker-style  = syntax "#273849"
      line-numbers-plus-style       = "#b8db87"
      line-numbers-zero-style       = "#3b4261"
  '';
in {
  options.my.programs.git.enable = lib.mkEnableOption "git";

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      userName = config.my.user.fullName;
      userEmail = config.my.user.email;
      delta = {
        enable = true;
        options = {
          features = deltaThemeName;
          syntax-theme = config.programs.bat.config.theme;
          navigate = true;
          line-numbers = false;
          side-by-side = false;
        };
      };
      includes = [
        {
          path = pkgs.fetchurl {
            url = "https://raw.githubusercontent.com/dandavison/delta/f49fd3b012067e34c101d7dfc6cc3bbac1fe5ccc/themes.gitconfig";
            sha256 = "09kfrlmrnj5h3vs8cwfs66yhz2zpgk0qnmajvsr57wsxzgda3mh6";
          };
        }
        {
          path = deltaTheme;
        }
      ];
      aliases = {
        st = "status";
        co = "checkout";
        cob = "checkout -b";
        sw = "switch";
        swc = "switch -c";
        sl = "switch -";
        sr = "!f() { git for-each-ref --count=30 --sort=-committerdate --format='%(refname:short)|%(committerdate:relative)|%(subject)|%(authorname)' refs/heads | column -ts'|' | fzf +m | cut -d ' ' -f 1 | xargs -o git switch; }; f";
        br = "branch";
        aa = "add --all";
        sa = "stash --all";
        rh = "reset HEAD";
        rh1 = "reset HEAD~1";
        cm = "commit";
        cma = "commit --amend";
        cmane = "commit --amend --no-edit";
        ll = "log --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
        l = "ll -15";
        lp = "l -p";
        df = "diff";
        dfc = "diff --cached";
        pf = "push --force-with-lease";
        prom = "pull --rebase origin master";
        ria = "rebase --interactive";
        r = "restore";
        rs = "restore --staged";
        cf = "chain first";
        cn = "chain next";
        cp = "chain prev";
        cl = "chain last";
        cr = "chain rebase";
      };
      extraConfig = {
        core = {
          editor = "nvim";
        };
        merge.conflictstyle = "diff3";
        pull.ff = "only";
        push = {
          default = "current";
          autoSetupRemote = true;
        };
        rebase = {
          autoStash = true;
          autoSquash = true;
        };
        rerere.enable = true;
        branch.sort = "-committerdate";
        column.ui = "auto";
        diff.colorMoved = "default";
      };
      ignores = [
        "local"
        ".venv"
        "*.egg-info"
        ".mypy_cache"
        "pyrightconfig.json"
        "Session.vim"
        ".vim"
        ".rgignore"
        ".direnv"
      ];
    };
    home.packages = [
      my.pkgs.git-smash
      my.pkgs.git-chain
    ];
  };
}
