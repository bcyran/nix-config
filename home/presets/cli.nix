{pkgs, ...}: {
  imports = [
    ../features/fish.nix
    ../features/tmux.nix
    ../features/git.nix
    ../features/btop.nix
    ../features/neovim
  ];

  home.packages = with pkgs; [
    wget
    curl
    ranger
    neofetch
    alejandra
    my.volume
  ];

  programs.eza.enable = true;
  programs.bat.enable = true;
  programs.ripgrep.enable = true;
  programs.fd.enable = true;
}
