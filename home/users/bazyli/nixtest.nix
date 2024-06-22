{
  home = {
    username = "bazyli";
    homeDirectory = "/home/bazyli";
  };

  imports = [
    ../../presets/core.nix
    ../../presets/cli.nix
    ../../presets/desktop.nix
    ../../presets/tokyonight.nix
  ];

  monitors = [
    # Left (builtin)
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
}
