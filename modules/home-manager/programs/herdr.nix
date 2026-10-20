{
  config,
  lib,
  ...
}: let
  cfg = config.my.programs.herdr;
  inherit (config.my.colorscheme) palette;
in {
  options.my.programs.herdr.enable = lib.mkEnableOption "herdr";

  config = lib.mkIf cfg.enable {
    programs.herdr = {
      enable = true;
      settings = {
        onboarding = false;
        keys = {
          prefix = "ctrl+a";

          focus_pane_left = ["alt+h"];
          focus_pane_right = ["alt+l"];
          focus_pane_down = ["alt+j"];
          focus_pane_up = ["alt+k"];

          resize_pane_left = ["alt+shift+h"];
          resize_pane_right = ["alt+shift+l"];
          resize_pane_down = ["alt+shift+j"];
          resize_pane_up = ["alt+shift+k"];

          previous_tab = ["alt+o" "prefix+o"];
          next_tab = ["alt+p" "prefix+p"];
          new_tab = ["prefix+c"];
          rename_tab = ["prefix+,"];
          close_tab = ["alt+X"];

          split_vertical = ["prefix+v" "prefix+|"];
          split_horizontal = ["prefix+h" "prefix+-"];
          rename_pane = ["prefix+."];
          close_pane = ["prefix+x"];
          zoom = ["prefix+z"];

          switch_workspace = ["prefix+1..9"];
          workspace_picker = ["alt+w" "prefix+w"];
          navigate_workspace_up = ["k" "up"];
          navigate_workspace_down = ["j" "down"];
          new_workspace = ["prefix+shift+w"];
          rename_workspace = ["prefix+;"];
          close_workspace = ["prefix+shift+X"];
        };
        ui = {
          sound = {
            enabled = true;
          };
          toast = {
            delivery = "herdr";
          };
        };
        theme = {
          custom = {
            panel_bg = "#${palette.base00}";
            sidebar_bg = "#${palette.base11}";
            active_row_bg = "#${palette.base02}";
            selection_bg = "#${palette.base02}";
            surface0 = "#${palette.base01}";
            surface1 = "#${palette.base02}";
            surface_dim = "#${palette.base10}";
            overlay0 = "#${palette.base03}";
            overlay1 = "#${palette.base04}";
            text = "#${palette.base05}";
            subtext0 = "#${palette.base04}";
            accent = "#${palette.accentPrimary}";
            blue = "#${palette.base0D}";
            teal = "#${palette.base0C}";
            green = "#${palette.base0B}";
            yellow = "#${palette.base0A}";
            peach = "#${palette.base09}";
            red = "#${palette.base08}";
            mauve = "#${palette.base0E}";
          };
        };
      };
    };
  };
}
