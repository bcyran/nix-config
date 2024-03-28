{
  writeShellApplication,
  substituteAll,
  rofi,
  hyprland,
  systemd,
  lockerBin,
  commonConfigPath,
}: let
  rofiBin = "${rofi}/bin/rofi";
  config = substituteAll {
    name = "powermenu.rasi";
    src = ./files/powermenu.rasi;
    inherit commonConfigPath;
  };
in
  writeShellApplication {
    name = "rofi-powermenu";
    runtimeInputs = [rofi hyprland systemd];
    text = ''
      opts=(Lock Logout Poweroff Suspend Hibernate Reboot)

      cmd="${rofiBin} -no-lazy-grab -dmenu -i -p System -config ${config}"

      choice=$(printf '%s\n' "''${opts[@]}" | ''${cmd})
      case "''${choice}" in
          Lock) ${lockerBin} ;;
          Logout) hyprctl dispatch exit ;;
          Poweroff) systemctl -i poweroff ;;
          Suspend) ${lockerBin} && systemctl suspend ;;
          Reboot) systemctl reboot ;;
          Hibernate) ${lockerBin} && systemctl hibernate ;;
      esac
    '';
  }
