{pkgs, ...}: {
  imports = [
    ../features/fish.nix
    ../features/tmux.nix
    ../features/git.nix
    ../features/ssh.nix
    ../features/btop.nix
  ];

  home.packages = with pkgs; [
    wget
    curl
    ranger
    neofetch
    cargo
    rustc
    nodejs
    alejandra
    my.volume
  ];

  programs.eza.enable = true;
  programs.bat.enable = true;
  programs.ripgrep.enable = true;
  programs.fd.enable = true;
}
