{my, ...}: let
  inherit (my.lib.const) domains;
in {
  imports = [
    my.homeManagerModules.default
    ../common/user.nix
  ];

  my = {
    configurations = {
      core.enable = true;
      user.enable = true;
    };
    presets = {
      cli.enable = true;
      desktop.enable = true;
      hyprland.enable = true;
      personal.enable = true;
      tokyonight.enable = true;
    };
    programs = {
      timewall.enable = true;
      cameractrls.enable = true;
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
    matchBlocks = {
      homelab = {
        host = "homelab";
        hostname = domains.homelab;
        user = "bazyli";
      };
      vps = {
        host = "vps";
        hostname = domains.vps;
        user = "bazyli";
      };
    };
  };
}
