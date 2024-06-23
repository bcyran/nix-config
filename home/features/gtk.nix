{pkgs, ...}: {
  gtk = {
    enable = true;

    font = {
      name = "Roboto";
      package = pkgs.roboto;
      size = 12;
    };

    iconTheme = {
      name = "Qogir";
      package = pkgs.qogir-icon-theme;
    };

    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
  };

  home.pointerCursor = {
    package = pkgs.numix-cursor-theme;
    name = "Numix-Cursor-Light";
    size = 16;
    gtk.enable = true;
    x11.enable = true;
  };
}
