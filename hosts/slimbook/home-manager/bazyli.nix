{
  my,
  inputs,
  config,
  ...
}: let
  inherit (my.lib.const) domains lan;
in {
  imports = [
    my.homeManagerModules.default
    ../common/user.nix
  ];

  sops = {
    defaultSopsFile = "${inputs.my-secrets}/slimbook_bazyli.yaml";
    secrets = {
      syncthing_key = {};
      syncthing_cert = {};
      syncthing_password = {};
    };
  };

  my = {
    configurations = {
      core.enable = true;
      user.enable = true;
      sops.enable = true;
    };
    presets = {
      cli.enable = true;
      desktop.enable = true;
      hyprland.enable = true;
      personal.enable = true;
      tokyonight.enable = true;
    };
    programs = {
      timewall.enable = false;
      cameractrls.enable = true;
      syncthing = {
        enable = true;
        keyFile = config.sops.secrets.syncthing_key.path;
        certFile = config.sops.secrets.syncthing_cert.path;
        passwordFile = config.sops.secrets.syncthing_password.path;
        inherit (my.lib.const.syncthing) devices;
        folders = {
          "KeePass" = "~/Dokumenty/03 - Obszary/Tożsamość/Hasła";
          "Portfolio" = "~/Dokumenty/03 - Obszary/Finanse/Portfolio Performance";
          "Sync" = "~/Sync";
        };
      };
    };
    hardware = {
      monitors = [
        # Left
        {
          description = "Dell Inc. DELL P2421D FJWHGC3";
          output = "DP-7";
          width = 2560;
          height = 1440;
          refreshRate = 60;
          x = 0;
          y = 0;
          scale = 1.0;
          transform = 1;
        }
        # Center
        {
          description = "Dell Inc. DELL U2723QE 3H7KF34";
          output = "DP-5";
          width = 3840;
          height = 2160;
          refreshRate = 60;
          x = 1440;
          y = 250;
          scale = 1.25;
          transform = 0;
        }
        # Right
        {
          description = "Dell Inc. DELL P2421D CGSHL93";
          output = "DP-6";
          width = 2560;
          height = 1440;
          refreshRate = 60;
          x = 4512;
          y = 0;
          scale = 1.0;
          transform = 3;
        }
        # Builtin (must be last)
        {
          description = "California Institute of Technology 0x1402 Unknown";
          output = "eDP-1";
          idByOutput = true;
          width = 2880;
          height = 1800;
          refreshRate = 90;
          scale = 1.5;
          enable = false;
        }
      ];
      networkInterfaces = {
        wired = "enp44s0";
        wireless = "wlo1";
      };
    };
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      homelab = {
        host = "homelab";
        hostname = lan.devices.homelab.domain;
        user = "bazyli";
      };
      vps = {
        host = "vps";
        hostname = domains.vps;
        user = "bazyli";
      };
    };
  };
  services = {
    podman.enable = true;
    kdeconnect.enable = true;
  };
}
