{
  config,
  lib,
  ...
}: let
  cfg = config.my.programs.firefox;
in {
  options.my.programs.firefox.enable = lib.mkEnableOption "firefox";

  config = lib.mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      profiles = {
        default = {
          id = 0;
          name = "default";
          isDefault = true;
          settings = let
            inherit (config.fonts.fontconfig) defaultFonts;
            sansSerifFont = builtins.elemAt defaultFonts.sansSerif 0;
            monospaceFont = builtins.elemAt defaultFonts.monospace 0;
          in {
            "brower.aboutConfig.showWarning" = false;
            "browser.contentblocking.category" = "strict";
            "browser.ctrlTab.sortByRecentlyUsed" = false;
            "browser.toolbars.bookmarks.visibility" = "always";
            "browser.search.defaultenginename" = "Kagi";
            "browser.search.order.1" = "Kagi";
            "dom.private-attribution.submission.enabled" = false;
            "extensions.formautofill.creditCards.enabled" = false;
            "font.name.sans-serif.x-western" = sansSerifFont;
            "font.name.monospace.x-western" = monospaceFont;
            "general.autoScroll" = true;
            "intl.accept_languages" = "pl,en-us,en";
            "intl.locale.requested" = "pl,en-US";
            "intl.regional_prefs.use_os_locales" = true;
            "privacy.fingerprintingProtection" = true;
            "extensions.activeThemeID" = "{f2dc20e1-4161-44e5-985c-6cc613ff1669}";

            "media.ffmpeg.vaapi.enabled" = true;
            "media.ffvpx.enabled" = false;
            "media.av1.enabled" = false;
            "gfx.webrender.all" = true;

            "devtools.cache.disabled" = true;
            "devtools.toolbox.host" = "window";
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
  };
}
