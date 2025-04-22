{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.my.programs.portfolio-performance;

  portfolioPackage = pkgs.portfolio;
in {
  options.my.programs.portfolio-performance.enable = lib.mkEnableOption "Portfolio Performance";

  config = lib.mkIf cfg.enable {
    home.packages = [portfolioPackage];

    xdg.desktopEntries.Portfolio = {
      type = "Application";
      name = "Portfolio Performance";
      comment = "Calculate Investment Portfolio Performance";
      categories = ["Office"];
      icon = "portfolio";
      exec = "env GDK_BACKEND=x11 ${lib.getExe portfolioPackage}";
      terminal = false;
    };
  };
}
