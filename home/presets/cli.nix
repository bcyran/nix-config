{pkgs, ...}: {
  imports = [
    ../features/fish.nix
    ../features/tmux.nix
    ../features/git.nix
    ../features/btop.nix
    ../features/direnv.nix
    ../features/nix-index.nix
    ../features/bat
    ../features/neovim
  ];

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
      btop.enable = true;
      direnv.enable = true;
    };
  };

  programs.eza.enable = true;
  programs.ripgrep.enable = true;
  programs.fd.enable = true;
}
