{
  my,
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.services.ntfy-mdmonitor;

  effectiveTopic =
    if cfg.topic != null
    then cfg.topic
    else "${config.networking.hostName}-mdadm";

  mdadmNtfy = pkgs.writeShellApplication {
    name = "mdadm-ntfy";
    runtimeInputs = with pkgs; [curl coreutils inetutils];
    text = builtins.readFile ./mdadm-ntfy.sh;
  };
  mdadmNtfyWithEnv = pkgs.writeShellApplication {
    name = "mdadm-ntfy-with-env";
    text = ''
      export NTFY_SERVER="${cfg.serverUrl}"
      export TOPIC="${effectiveTopic}"
      # `source` will not work due to special chars
      # shellcheck disable=SC2046
      export $(${pkgs.coreutils}/bin/cat "${toString cfg.environmentFile}" | ${pkgs.findutils}/bin/xargs)

      exec ${lib.getExe mdadmNtfy} "$@"
    '';
  };
in {
  options.my.services.ntfy-mdmonitor = let
    serviceName = "ntfy.sh mdmonitor notifications";
  in {
    enable = lib.mkEnableOption serviceName;
    environmentFile = my.lib.options.mkEnvironmentFileOption serviceName;

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
    boot.swraid = {
      mdadmConf = ''
        PROGRAM ${lib.getExe mdadmNtfyWithEnv}
      '';
    };
  };
}
