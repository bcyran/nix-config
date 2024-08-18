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
        fish.enable = mkDefault true;
        neovim.enable = mkDefault true;
        git.enable = mkDefault true;
        tmux.enable = mkDefault true;
        bat.enable = mkDefault true;
        btop.enable = mkDefault true;
        direnv.enable = mkDefault true;
        nix-index.enable = mkDefault true;
      };
    };

    programs.eza.enable = mkDefault true;
    programs.ripgrep.enable = mkDefault true;
    programs.fd.enable = mkDefault true;
  };
}
