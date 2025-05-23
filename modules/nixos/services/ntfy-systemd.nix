{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.services.ntfy-systemd;

  effectiveTopic =
    if cfg.topic != null
    then cfg.topic
    else "${config.networking.hostName}-systemd";
in {
  options.my.services.ntfy-systemd = let
    serviceName = "ntfy.sh systemd notifications";
  in {
    enable = lib.mkEnableOption serviceName;

    serverUrl = lib.mkOption {
      type = lib.types.str;
      default = "https://ntfy.example.com";
      description = "The ntfy server URL.";
    };

    topic = lib.mkOption {
      type = with lib.types; nullOr str;
      default = null;
      description = "The ntfy topic to send notifications to.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services."ntfy-failed@" = {
      description = "Send ntfy notification about %i failure";
      scriptArgs = "%i";
      script = ''
        ${pkgs.curl}/bin/curl \
          -H "Title: Systemd: $1 failed" \
          -H "Tags: warning" \
          -d "$(journalctl --unit $1 --lines 10 --reverse --no-pager --boot | head -c 4095)" \
          ${cfg.serverUrl}/${effectiveTopic}
      '';
    };
  };
}
