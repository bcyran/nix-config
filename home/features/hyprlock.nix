{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (config.colorscheme) palette;
  font = "Roboto Condensed";
  lockServiceScript = pkgs.writeShellApplication {
    name = "hyprlock-sd-notify";
    runtimeInputs = with pkgs; [hyprlock systemd];
    text = ''
      hyprlock | while read -r line; do
        echo "$line"
        if [[ "$line" == *'onLockLocked called'* ]]; then
          systemd-notify --ready
        fi
      done
    '';
  };
  lockServiceScriptBin = lib.getExe lockServiceScript;
in {
  programs.hyprlock = {
    enable = true;

    settings = {
      general = {
        hide_cursor = true;
      };

      background = [
        {
          monitor = "";
          color = "rgb(${palette.base00})";
        }
      ];

      label = [
        {
          monitor = "";
          text = "$TIME";
          font_size = 100;
          font_family = font;
          color = "rgb(${palette.base05})";
          position = "0, 50";
          valign = "center";
          halign = "center";
        }
      ];

      input-field = [
        {
          monitor = "";
          size = "300, 50";
          position = "0, -100";
          outline_thickness = 0;
          dots_center = true;
          fade_on_empty = true;
          fade_timeout = 3000;
          placeholder_text = ''<span font_family="${font}" font_style="italic">$PROMPT</span>'';
          fail_text = ''<span font_family="${font}" font_style="italic">$FAIL <b>($ATTEMPTS)</b></span>'';
          font_color = "rgb(${palette.base00})";
          inner_color = "rgb(${palette.base05})";
          check_color = "rgb(${palette.accentPrimary})";
          fail_color = "rgb(${palette.error})";
          capslock_color = "rgb(${palette.warning})";
          numlock_color = "rgb(${palette.warning})";
        }
      ];
    };
  };

  # This requires `services.systemd-lock-handler.enable = true` in the system config.
  systemd.user.services.lock = {
    Unit = {
      Description = "Screen locker.";
      OnSuccess = ["unlock.target"];
      PartOf = ["lock.target"];
      After = ["lock.target"];
    };
    # Change this to forking service without custom script if hyprlock implements forking mode.
    # See: https://github.com/hyprwm/hyprlock/issues/184
    Service = {
      Type = "notify";
      NotifyAccess = "all";
      ExecStart = lockServiceScriptBin;
      Restart = "on-failure";
      RestartSec = 0;
    };
    Install = {
      WantedBy = ["lock.target"];
    };
  };
}
