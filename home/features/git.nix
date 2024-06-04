{pkgs, ...}: {
  programs.git = {
    enable = true;
    userName = "Bazyli Cyran";
    userEmail = "bazyli@cyran.dev";
    delta = {
      enable = true;
      options = {
        features = "zebra-dark";
        syntax-theme = "TwoDark";
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
    ];
    aliases = {
      st = "status";
      co = "checkout";
      cob = "checkout -b";
      sw = "switch";
      swc = "switch -c";
      sl = "switch -";
      sr = "!f() { git for-each-ref --count=10 --sort=-committerdate --format='%(refname:short)|%(committerdate:relative)|%(subject)|%(authorname)' refs/heads | column -ts'|' | fzf +m | cut -d ' ' -f 1 | xargs -o git switch; }; f";
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
      ria = "rebase --interactive --autosquash --autostash";
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
        excludesfile = "~/.gitignore";
      };
      merge.conflictstyle = "diff3";
      pull.ff = "only";
      rerere.enable = true;
      branch.sort = "-committerdate";
      column.ui = "auto";
      diff.colorMoved = "default";
    };
  };
  home.file.".gitignore".text = ''
    # for keeping some random stuff in project dirs without cluttering git
    local

    # Python
    .venv
    *.egg-info
    .mypy_cache
    pyrightconfig.json

    # Vim
    Session.vim
    .vim

    # ripgrep
    .rgignore
  '';
}