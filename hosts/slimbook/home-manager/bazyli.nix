{
  inputs,
  outputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.nix-colors.homeManagerModules.default
    inputs.nix-index-database.hmModules.nix-index
    inputs.anyrun.homeManagerModules.default
    outputs.homeManagerModules.default
  ];

  my = {
    user = {
      name = "bazyli";
      fullName = "Bazyli Cyran";
      email = "bazyli@cyran.dev";
      home = "/home/bazyli";
      shell = pkgs.fish;
      uid = 1000;
      groups = ["networkmanager" "wheel" "video"];
    };
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
    hardware = {
      monitors = [
        # Left (builtin)
        {
          description = "California Institute of Technology 0x1402";
          output = "eDP-1";
          width = 2880;
          height = 1800;
          refreshRate = 90;
          x = 0;
          y = 325;
          scale = 1.5;
        }
        # Center
        {
          description = "Dell Inc. DELL P2421D FJWHGC3";
          output = "DP-6";
          altOutput = "DP-8";
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
          altOutput = "DP-9";
          width = 2560;
          height = 1440;
          refreshRate = 60;
          x = 4480;
          y = 0;
          transform = 3;
        }
      ];
      networkInterfaces = {
        wired = "enp44s0";
        wireless = "wlo1";
      };
    };
  };
}
