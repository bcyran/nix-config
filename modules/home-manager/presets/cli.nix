{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkDefault;
  cfg = config.my.presets.cli;
in {
  options.my.presets.cli.enable = lib.mkEnableOption "cli";

  config = lib.mkIf cfg.enable {
    my = {
      programs = {
        fish.enable = mkDefault true;
        starship.enable = mkDefault true;
        atuin.enable = mkDefault true;
        neovim.enable = mkDefault true;
        git.enable = mkDefault true;
        gh.enable = mkDefault true;
        tmux.enable = mkDefault true;
        zellij.enable = mkDefault true;
        bat.enable = mkDefault true;
        fzf.enable = mkDefault true;
        btop.enable = mkDefault true;
        direnv.enable = mkDefault true;
        nix-index.enable = mkDefault true;
        yazi.enable = mkDefault true;
      };
    };

    programs = {
      zoxide.enable = mkDefault true;
      eza.enable = mkDefault true;
      ripgrep.enable = mkDefault true;
      fd.enable = mkDefault true;
    };

    home.packages = with pkgs; [
      wget
      curl
      httpie
      dust
      dysk
      glow
      fastfetch
      alejandra
      statix
    ];
  };
}
