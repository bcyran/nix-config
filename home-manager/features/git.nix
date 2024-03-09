{ pkgs, ... }:
{
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
      { path = "${pkgs.delta-themes}/share/themes.gitconfig"; }
    ];
    aliases = {
      st = "status";
      co = "checkout";
      cob = "checkout -b";
      sw = "switch";
      swc = "switch -c";
      br = "branch";
      aa = "add -all";
      rh = "reset HEAD";
      rh1 = "reset HEAD~1";
      cm = "commit";
      cma = "commit --amend";
      cmane = "commit --amend --no-edit";
      l = "log --oneline -10";
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
