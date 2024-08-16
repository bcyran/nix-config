{pkgs, ...}: {
  home.packages = with pkgs; [
    wget
    curl
    ranger
    dust
    neofetch
    alejandra
    my.volume
  ];

  my = {
    programs = {
      fish.enable = true;
      neovim.enable = true;
      git.enable = true;
      tmux.enable = true;
      bat.enable = true;
      btop.enable = true;
      direnv.enable = true;
      nix-index.enable = true;
    };
  };

  programs.eza.enable = true;
  programs.ripgrep.enable = true;
  programs.fd.enable = true;
}
