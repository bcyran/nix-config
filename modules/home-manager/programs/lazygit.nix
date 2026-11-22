{
  config,
  lib,
  ...
}: let
  cfg = config.my.programs.lazygit;
  inherit (config.my.colorscheme) palette;
in {
  options.my.programs.lazygit.enable = lib.mkEnableOption "lazygit";

  config = lib.mkIf cfg.enable {
    programs.lazygit = {
      enable = true;
      settings = {
        gui = {
          colorScheme = "dark";
          theme = {
            activeBorderColor = ["#${palette.accentPrimary}" "bold"];
            inactiveBorderColor = ["#${palette.base03}"];
            searchingActiveBorderColor = ["#${palette.base0A}" "bold"];
            optionsTextColor = ["#${palette.base0C}"];
            selectedLineFgColor = ["#${palette.base05}" "bold"];
            selectedLineBgColor = ["#${palette.base02}"];
            inactiveViewSelectedLineBgColor = ["#${palette.base01}"];
            cherryPickedCommitFgColor = ["#${palette.base00}"];
            cherryPickedCommitBgColor = ["#${palette.base0E}"];
            markedBaseCommitFgColor = ["#${palette.base00}"];
            markedBaseCommitBgColor = ["#${palette.base0A}"];
            unstagedChangesColor = ["#${palette.base08}"];
            defaultFgColor = ["#${palette.base05}"];
          };
        };
      };
    };
  };
}
