{
  writeShellApplication,
  substituteAll,
  rofi,
  hyprland,
  systemd,
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
          Lock) loginctl lock-session ;;
          Logout) hyprctl dispatch exit ;;
          Poweroff) systemctl -i poweroff ;;
          Suspend) systemctl -i suspend ;;
          Reboot) systemctl -i reboot ;;
          Hibernate) systemctl -i hibernate ;;
      esac
    '';
  }
