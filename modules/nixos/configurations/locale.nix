{
  lib,
  config,
  ...
}: let
  cfg = config.my.configurations.locale;
in {
  options.my.configurations.locale.enable = lib.mkEnableOption "locale";

  config = lib.mkIf cfg.enable {
    i18n = {
      defaultLocale = "pl_PL.UTF-8";
      supportedLocales = [
        "en_US.UTF-8/UTF-8"
        "pl_PL.UTF-8/UTF-8"
      ];
    };
    location.provider = "geoclue2";
    time.timeZone = "Europe/Warsaw";
  };
}
