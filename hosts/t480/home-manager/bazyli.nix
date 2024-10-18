{my, ...}: {
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
      personal.enable = true;
      tokyonight.enable = true;
    };
    programs = {
      syncthing.enable = false;
    };
    hardware = {
      monitors = [
        {
          description = "BOE 0x074F";
          output = "eDP-1";
          width = 1920;
          height = 1080;
          refreshRate = 60;
          x = 0;
          y = 325;
        }
        # Center
        {
          description = "Dell Inc. DELL P2421D FJWHGC3";
          output = "DP-6";
          width = 2560;
          height = 1440;
          refreshRate = 60;
          x = 1920;
          y = 325;
        }
        # Right
        {
          description = "Dell Inc. DELL P2421D CGSHL93";
          output = "DP-7";
          width = 2560;
          height = 1440;
          refreshRate = 60;
          x = 4480;
          y = 0;
          transform = 3;
        }
      ];
      networkInterfaces = {
        wired = "enp0s31f6";
        wireless = "wlp3s0";
      };
    };
  };
}
