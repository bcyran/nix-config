{
  my,
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.configurations.mdadm;

  effectiveTopic =
    if cfg.ntfy.topic != null
    then cfg.ntfy.topic
    else "${config.networking.hostName}-mdadm";

  mdadmNtfy = pkgs.writeShellApplication {
    name = "mdadm-ntfy";
    runtimeInputs = with pkgs; [curl coreutils inetutils];
    text = builtins.readFile ./mdadm-ntfy.sh;
  };
  mdadmNtfyWithEnv = pkgs.writeShellApplication {
    name = "mdadm-ntfy-with-env";
    text = ''
      export NTFY_SERVER="${cfg.ntfy.serverUrl}"
      export TOPIC="${effectiveTopic}"
      # `source` will not work due to special chars
      # shellcheck disable=SC2046
      export $(${pkgs.coreutils}/bin/cat "${toString cfg.ntfy.environmentFile}" | ${pkgs.findutils}/bin/xargs)

      exec ${lib.getExe mdadmNtfy} "$@"
    '';
  };
in {
  options.my.configurations.mdadm = let
    serviceName = "ntfy.sh mdmonitor notifications";
  in {
    enable = lib.mkEnableOption serviceName;

    ntfy = {
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
      environmentFile = my.lib.options.mkEnvironmentFileOption serviceName;
    };
  };

  config = lib.mkIf cfg.enable {
    boot = {
      swraid = {
        enable = true;
        mdadmConf = ''
          PROGRAM ${lib.getExe mdadmNtfyWithEnv}
        '';
      };
    };
  };
}
