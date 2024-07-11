{lib, ...}: {
  i18n = {
    defaultLocale = lib.mkDefault "pl_PL.UTF-8";
    supportedLocales = lib.mkDefault [
      "en_US.UTF-8/UTF-8"
      "pl_PL.UTF-8/UTF-8"
    ];
  };
  location.provider = "geoclue2";
  time.timeZone = lib.mkDefault "Europe/Warsaw";
}
