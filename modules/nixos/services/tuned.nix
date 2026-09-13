{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkDefault;
  cfg = config.my.services.tuned;

  powerProfilesScript = pkgs.writeShellApplication {
    name = "tuned-power-profiles";
    runtimeInputs = [
      config.services.tuned.package
      pkgs.coreutils
      pkgs.systemd
    ];
    text = ''
      power_state() {
        case "$(busctl --no-pager get-property org.freedesktop.UPower /org/freedesktop/UPower org.freedesktop.UPower OnBattery 2>/dev/null)" in
          "b true") echo "battery" ;;
          "b false") echo "ac" ;;
          *) echo "unknown" ;;
        esac
      }

      apply() {
        tuned-adm profile "$1"
      }

      last=""
      while true; do
        cur="$(power_state)"
        if [ "$cur" != "unknown" ] && [ "$cur" != "$last" ]; then
          if [ "$cur" = "battery" ]; then
            profile="powersave"
          else
            profile="throughput-performance"
          fi
          if apply "$profile"; then
            echo "switched to tuned profile '$profile' (power: $cur)"
            last="$cur"
          fi
        fi
        sleep 5
      done
    '';
  };
in {
  options.my.services.tuned.enable = lib.mkEnableOption "tuned power manager";

  config = lib.mkIf cfg.enable {
    services.tuned = {
      enable = mkDefault true;
      ppdSupport = mkDefault true;
      ppdSettings.main.battery_detection = false;
    };

    systemd.services.tuned-power-profiles = {
      description = "Switch tuned power profile based on the power source";
      wantedBy = ["graphical.target"];
      after = ["tuned.service" "tuned-ppd.service"];
      serviceConfig = {
        Type = "simple";
        Restart = "on-failure";
        RestartSec = "5s";
        ExecStart = lib.getExe powerProfilesScript;
      };
    };
  };
}
