{
  my,
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkDefault;
  cfg = config.my.presets.desktop;
in {
  options.my.presets.desktop.enable = lib.mkEnableOption "desktop";

  config = lib.mkIf cfg.enable {
    my = {
      programs = {
        alacritty.enable = mkDefault true;
        kitty.enable = mkDefault true;
        keepassxc.enable = mkDefault true;
        firefox.enable = mkDefault true;
        spotify.enable = mkDefault true;
        udiskie.enable = mkDefault true;
        zathura.enable = mkDefault true;
      };
      configurations = {
        gtk.enable = mkDefault true;
        xdg.enable = mkDefault true;
        polkit.enable = mkDefault true;
      };
    };

    programs = {
      chromium.enable = mkDefault true;
    };

    home.packages = with pkgs; [
      # Fonts
      inter
      corefonts
      noto-fonts
      noto-fonts-emoji
      noto-fonts-cjk-sans
      nerd-fonts.jetbrains-mono

      libnotify
      wl-clipboard
      playerctl
      philipstv
      my.pkgs.volume
      my.pkgs.backlight
      my.pkgs.wallpaper
      my.pkgs.scr
      my.pkgs.philipstv-gui
    ];

    fonts.fontconfig = {
      enable = mkDefault true;
      defaultFonts = {
        sansSerif = mkDefault ["Inter"];
        serif = mkDefault ["Noto Serif"];
        monospace = mkDefault ["JetBrainsMonoNL NF"];
        emoji = mkDefault ["Noto Color Emoji"];
      };
    };
  };
}
