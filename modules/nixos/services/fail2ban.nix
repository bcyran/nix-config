{
  my,
  config,
  lib,
  ...
}: let
  cfg = config.my.services.fail2ban;
in {
  options.my.services.fail2ban.enable = lib.mkEnableOption "Fail2ban";

  config = lib.mkIf cfg.enable {
    services.fail2ban = {
      enable = true;
      ignoreIP = [
        my.lib.const.wireguard.subnet
      ];
      bantime = "10m";
      bantime-increment = {
        enable = true;
        multipliers = "1 2 4 8 16 32 64";
      };
    };
  };
}
