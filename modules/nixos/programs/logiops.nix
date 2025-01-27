{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.my.programs.logiops;

  logiopsBin = lib.getExe pkgs.logiops;
in {
  options.my.programs.logiops.enable = lib.mkEnableOption "logiops";

  config = lib.mkIf cfg.enable {
    # This is in process of being added to nixpkgs: https://github.com/NixOS/nixpkgs/issues/226575
    systemd = {
      services.logiops = {
        description = "Logitech Configuration Daemon";
        documentation = ["https://github.com/PixlOne/logiops"];
        startLimitIntervalSec = 0;
        wantedBy = ["graphical.target"];
        after = ["multi-user.target"];
        wants = ["multi-user.target"];
        serviceConfig = {
          Type = "simple";
          ExecStart = logiopsBin;
        };
      };
    };

    # Add a `udev` rule to restart `logiops` when the mouse is connected
    # https://github.com/PixlOne/logiops/issues/239#issuecomment-1044122412
    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="input", ATTRS{id/vendor}=="046d", RUN{program}="${config.systemd.package}/bin/systemctl --no-block try-restart logiops.service"
    '';

    environment = {
      systemPackages = [pkgs.logiops];
      etc."logid.cfg" = {
        text = ''
          devices: ({
              name: "Wireless Mouse MX Master 2S";

              smartshift:
              {
                  on: true;
                  threshold: 15;
              };

              hiresscroll:
              {
                  hires: true;
                  invert: false;
                  target: false;
              };

              dpi: 2000;

              buttons: (
                  {
                      cid: 0xc4;
                      action =
                      {
                          type = "ToggleSmartshift";
                      };
                  },
                  {
                      cid: 0xc3;
                      action =
                      {
                          type = "Keypress";
                          keys: ["BTN_MIDDLE"];
                      };
                  },
              );
          });
        '';
      };
    };
  };
}
