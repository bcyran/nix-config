let
  editorDesktop = "nvim.desktop";
in {
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/plain" = [editorDesktop];
      "text/markdown" = [editorDesktop];
      "text/html" = [editorDesktop];
      "text/javascript" = [editorDesktop];
      "text/xml" = [editorDesktop];
      "application/x-shellscript" = [editorDesktop];
    };
  };
}
