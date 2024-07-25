{config, ...}: let
  textEditor = "nvim.desktop";
  webBrowser = "firefox.desktop";
  pdfViewer = "org.pwmt.zathura-pdf-mupdf.desktop";
  imageViewer = "org.gnome.gThumb.desktop";

  makeAssociations = program: type: subtypes:
    builtins.listToAttrs (map (subtype: {
        name = "${type}/${subtype}";
        value = program;
      })
      subtypes);

  associations =
    makeAssociations textEditor "text" [
      "plain"
      "markdown"
      "javascript"
      "xml"
    ]
    // makeAssociations textEditor "application" [
      "json"
      "x-shellscript"
    ]
    // makeAssociations webBrowser "application" [
      "x-extension-htm"
      "x-extension-html"
      "x-extension-shtml"
      "x-extension-xht"
      "x-extension-xtml"
      "xhtml+xml"
    ]
    // makeAssociations webBrowser "x-scheme-handler" [
      "http"
      "https"
      "ftp"
    ]
    // makeAssociations webBrowser "text" ["html"]
    // makeAssociations imageViewer "image" [
      "jpeg"
      "png"
      "gif"
      "svg"
    ]
    // makeAssociations pdfViewer "application" ["pdf"];
in {
  xdg = {
    enable = true;

    mimeApps = {
      enable = true;
      defaultApplications = associations;
    };

    userDirs = let
      homeDir = config.home.homeDirectory;
    in {
      enable = true;
      desktop = "${homeDir}/Pulpit";
      documents = "${homeDir}/Dokumenty";
      download = "${homeDir}/Pobrane";
      music = "${homeDir}/Muzyka";
      pictures = "${homeDir}/Obrazy";
      publicShare = "${homeDir}/Udostępnione";
      templates = "${homeDir}/Szablony";
      videos = "${homeDir}/Wideo";
    };
  };
}
