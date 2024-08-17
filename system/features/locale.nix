{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.my.configurations.locale;
in {
  options.my.configurations.locale.enable = mkEnableOption "locale";

  config = mkIf cfg.enable {
    i18n = {
      defaultLocale = mkDefault "pl_PL.UTF-8";
      supportedLocales = mkDefault [
        "en_US.UTF-8/UTF-8"
        "pl_PL.UTF-8/UTF-8"
      ];
    };
    location.provider = "geoclue2";
    time.timeZone = mkDefault "Europe/Warsaw";
  };
}
