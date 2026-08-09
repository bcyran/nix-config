{
  config,
  lib,
  my,
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
    programs.opencode = {
      enable = true;
      settings = {
        autoupdate = false;
        plugin = [
          "superpowers@git+https://github.com/obra/superpowers.git"
          "opencode-rules@latest"
        ];
      };
      tui = {
        theme = "tokyonight";
        plugin = [
          "opencode-rules@latest"
        ];
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
      ];
      targets.opencode.enable = true;
    };
  };
}
