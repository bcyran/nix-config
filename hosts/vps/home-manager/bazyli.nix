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
      tokyonight.enable = true;
    };
    programs = {
      zellij = {
        enable = true;
        enableShellIntegration = true;
      };
    };
  };
}
