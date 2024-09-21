{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.my.programs.obsidian;

  obsidianPackage = pkgs.obsidian;
  obsidianOptions = [
    "--enable-features=UseOzonePlatform"
    "--ozone-platform=wayland"
  ];
in {
  options.my.programs.obsidian.enable = lib.mkEnableOption "obsidian";

  config = lib.mkIf cfg.enable {
    home.packages = [obsidianPackage];

    # We create a custom desktop entry to use the wayland backend.
    xdg.desktopEntries.obsidian = let
      optionsString = lib.concatStringsSep " " obsidianOptions;
    in {
      type = "Application";
      name = "Obsidian";
      genericName = "Personal knowledge base";
      comment = "Knowledge base and note taking app";
      categories = ["Office"];
      icon = "obsidian";
      exec = "${obsidianPackage}/bin/obsidian ${optionsString} %u";
      mimeType = ["x-scheme-handler/obsidian"];
    };
  };
}
