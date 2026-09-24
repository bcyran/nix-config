{
  config,
  lib,
  my,
  pkgs,
  ...
}: let
  cfg = config.my.programs.opencode;
  agentLib = my.inputs.agent-skills.lib.agent-skills;
  skillSources = agentLib.sourcesFromLock {
    manifestsDir = "${my}/agent-skills/sources";
    lockFile = "${my}/agent-skills/sources.lock.json";
  };
in {
  options.my.programs.opencode.enable = lib.mkEnableOption "opencode";

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.rtk
      pkgs.codegraph
    ];

    programs.opencode = {
      enable = true;
      settings = {
        autoupdate = false;
        plugin = [
          "opencode-rules@latest"
          "${pkgs.rtk.src}/hooks/opencode/rtk.ts"
        ];
        mcp.servers = {
          codegraph = {
            type = "local";
            command = [
              (lib.getExe pkgs.codegraph)
              "serve"
              "--mcp"
            ];
          };
          nixos = {
            type = "local";
            command = [(lib.getExe pkgs.mcp-nixos)];
          };
        };
      };
      tui = {
        theme = "tokyonight";
        plugin = ["opencode-rules@latest"];
      };
    };

    programs.agent-skills = {
      enable = true;
      sources = skillSources;
      skills.enable = [
        "simple-english"
        "engineering/grill-with-docs"
        "productivity/grilling"
        "engineering/domain-modeling"
        "caveman"
        "ponytail"
        "i-have-adhd"
      ];
      targets.opencode.enable = true;
    };
  };
}
