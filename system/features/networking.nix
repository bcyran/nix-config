{
  pkgs,
  lib,
  ...
}: let
  wifiWiredExclusiveDispatcher = pkgs.writeShellApplication {
    name = "wifi-wired-exclusive.sh";
    runtimeInputs = with pkgs; [networkmanager gnugrep];
    text = ''
      export LC_ALL=C

      enable_disable_wifi() {
        result=$(nmcli dev | grep "ethernet" | grep -w "connected")
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
  wifiWiredExclusiveDispatcherBin = lib.getExe wifiWiredExclusiveDispatcher;
in {
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
}
