{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    extraLuaConfig = ''
      require("config.lazy")
    '';
  };
  xdg.configFile."nvim/lua".source = ./files/lua;
}
