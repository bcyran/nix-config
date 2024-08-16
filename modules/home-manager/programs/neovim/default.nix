{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.my.programs.neovim;

  alacrittyBin = "${pkgs.alacritty}/bin/alacritty";
  nvimBin = "${pkgs.neovim}/bin/nvim";
in {
  options.my.programs.neovim.enable = mkEnableOption "neovim";

  config = mkIf cfg.enable {
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

    xdg.desktopEntries.nvim = {
      type = "Application";
      name = "Neovim";
      genericName = "Text Editor";
      comment = "Edit text files";
      categories = ["Utility" "TextEditor"];
      icon = "nvim";
      exec = "${alacrittyBin} -e ${nvimBin} %F";
      mimeType = [
        "text/english"
        "text/plain"
        "text/x-makefile"
        "text/x-c++hdr"
        "text/x-c++src"
        "text/x-chdr"
        "text/x-csrc"
        "text/x-java"
        "text/x-moc"
        "text/x-pascal"
        "text/x-tcl"
        "text/x-tex"
        "application/x-shellscript"
        "text/x-c"
        "text/x-c++"
      ];
      startupNotify = false;
      terminal = false;
    };
  };
}
