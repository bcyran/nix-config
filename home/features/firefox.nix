{
  programs.firefox = {
    enable = true;
    profiles = {
      default = {
        id = 0;
        name = "default";
        isDefault = true;
        settings = {
          "browser.search.defaultenginename" = "Kagi";
          "browser.search.order.1" = "Kagi";
          "media.ffmpeg.vaapi.enabled" = true;
          "media.ffvpx.enabled" = false;
          "media.av1.enabled" = false;
          "gfx.webrender.all" = true;
        };
        search = {
          force = true;
          default = "Kagi";
          order = ["Kagi"];
          engines = {
            "Kagi" = {
              urls = [{template = "https://kagi.com/search?q={searchTerms}";}];
              iconUpdateURL = "https://kagi.com/favicon.ico";
              updateInterval = 24 * 60 * 60 * 1000;
              definedAlises = ["@kagi"];
            };
            "Bing".metadata.hidden = true;
            "Google".metadata.hidden = true;
            "eBay".metadata.hidden = true;
            "Wolne Lektury".metadata.hidden = true;
          };
        };
      };
    };
  };
}
