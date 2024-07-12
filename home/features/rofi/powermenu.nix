{
  writeShellApplication,
  substituteAll,
  rofi,
  hyprland,
  systemd,
  commonConfigPath,
}: let
  rofiBin = "${rofi}/bin/rofi";
  loginctlBin = "${systemd}/bin/loginctl";
  hyprctlBin = "${hyprland}/bin/hyprctl";
  systemctlBin = "${systemd}/bin/systemctl";
  config = substituteAll {
    name = "powermenu.rasi";
    src = ./files/powermenu.rasi;
    inherit commonConfigPath;
  };
in
  writeShellApplication {
    name = "rofi-powermenu";
    text = ''
      opts=(Lock Logout Poweroff Suspend Hibernate Reboot)

      cmd="${rofiBin} -no-lazy-grab -dmenu -i -p System -config ${config}"

      choice=$(printf '%s\n' "''${opts[@]}" | ''${cmd})
      case "''${choice}" in
          Lock) ${loginctlBin} lock-session ;;
          Logout) ${hyprctlBin} dispatch exit ;;
          Poweroff) ${systemctlBin} -i poweroff ;;
          Suspend) ${systemctlBin} -i suspend ;;
          Reboot) ${systemctlBin} -i reboot ;;
          Hibernate) ${systemctlBin} -i hibernate ;;
      esac
    '';
  }
