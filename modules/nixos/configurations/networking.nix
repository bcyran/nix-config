{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.my.configurations.networking;

  wifiWiredExclusiveDispatcher = pkgs.writeShellApplication {
    name = "wifi-wired-exclusive.sh";
    runtimeInputs = with pkgs; [networkmanager gnugrep];
    text = ''
      export LC_ALL=C

      enable_disable_wifi() {
        # Do not fail the script on exit code 1 (set -e) due to lack of matches
        result=$(nmcli dev | { grep "ethernet" || test $? = 1; } | { grep -w "connected" || test $? = 1; })
        if [[ -n "$result" ]]; then
          echo "Detected wired connection, disabling Wi-Fi"
          nmcli radio wifi off
        else
          echo "Detected no wired connection, enabling Wi-Fi"
          nmcli radio wifi on
        fi
      }

      case "$2" in
        up | down) enable_disable_wifi ;;
      esac
    '';
  };
  wifiWiredExclusiveDispatcherBin = getExe wifiWiredExclusiveDispatcher;
in {
  options.my.configurations.networking.enable = mkEnableOption "networking";

  config = mkIf cfg.enable {
    networking = {
      networkmanager = {
        enable = true;
        dispatcherScripts = [
          {
            source = wifiWiredExclusiveDispatcherBin;
            type = "basic";
          }
        ];
      };
    };
    systemd.services.NetworkManager-dispatcher.enable = true;
  };
}
