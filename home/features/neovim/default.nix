{pkgs, ...}: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    extraLuaConfig = ''
      require("config.lazy")
    '';
    extraPackages = with pkgs; [
      gcc # for treesitter
      wl-clipboard
      lua-language-server
      dockerfile-language-server-nodejs
      nil
      shellcheck
      shfmt
      stylua
      yaml-language-server
      vscode-langservers-extracted
    ];
  };
  xdg.configFile."nvim/lua".source = ./files/lua;
}
