{my, ...}: {
  imports = [
    my.homeManagerModules.default
    ../common/host.nix
  ];

  my = {
    configurations = {
      core.enable = true;
      user.enable = true;
    };
    presets = {
      cli.enable = true;
    };
    programs = {
      zellij = {
        enable = true;
        enableShellIntegration = true;
      };
    };
  };
}
