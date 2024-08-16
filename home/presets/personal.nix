{pkgs, ...}: {
  home.packages = with pkgs; [
    portfolio
    gnucash
    obsidian
    gimp
    libreoffice-fresh
    anydesk
    calibre
    gthumb
    protonvpn-gui
    vlc
    tor-browser
    gnome.gnome-boxes
  ];

  my = {
    programs = {
      signal.enable = true;
    };
  };
}
