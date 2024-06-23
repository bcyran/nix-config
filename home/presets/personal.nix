{pkgs, ...}: {
  home.packages = with pkgs; [
    signal-desktop
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
  ];
}
