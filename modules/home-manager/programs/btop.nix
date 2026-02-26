{
  config,
  lib,
  ...
}: let
  inherit (config.colorScheme) palette;
  cfg = config.my.programs.btop;
in {
  options.my.programs.btop.enable = lib.mkEnableOption "btop";

  config = lib.mkIf cfg.enable {
    programs.btop = {
      enable = true;
      settings = {
        color_theme = config.colorScheme.slug;
      };
      themes = {
        "${config.colorScheme.slug}" = ''
          # Main bg
          theme[main_bg]="#${palette.base00}"

          # Main text color
          theme[main_fg]="#${palette.base05}"

          # Title color for boxes
          theme[title]="#${palette.base05}"

          # Highlight color for keyboard shortcuts
          theme[hi_fg]="#${palette.accentPrimary}"

          # Background color of selected item in processes box
          theme[selected_bg]="#${palette.base02}"

          # Foreground color of selected item in processes box
          theme[selected_fg]="#${palette.base05}"

          # Color of inactive/disabled text
          theme[inactive_fg]="#${palette.base03}"

          # Misc colors for processes box including mini cpu graphs, details memory graph and details status text
          theme[proc_misc]="#${palette.base0C}"

          # Cpu box outline color
          theme[cpu_box]="#${palette.base03}"

          # Memory/disks box outline color
          theme[mem_box]="#${palette.base03}"

          # Net up/down box outline color
          theme[net_box]="#${palette.base03}"

          # Processes box outline color
          theme[proc_box]="#${palette.base03}"

          # Box divider line and small boxes line color
          theme[div_line]="#${palette.base03}"

          # Temperature graph colors
          theme[temp_start]="#${palette.base0B}"
          theme[temp_mid]="#${palette.base0A}"
          theme[temp_end]="#${palette.base08}"

          # CPU graph colors
          theme[cpu_start]="#${palette.base0B}"
          theme[cpu_mid]="#${palette.base0A}"
          theme[cpu_end]="#${palette.base08}"

          # Mem/Disk free meter
          theme[free_start]="#${palette.base0B}"
          theme[free_mid]="#${palette.base0A}"
          theme[free_end]="#${palette.base08}"

          # Mem/Disk cached meter
          theme[cached_start]="#${palette.base0B}"
          theme[cached_mid]="#${palette.base0A}"
          theme[cached_end]="#${palette.base08}"

          # Mem/Disk available meter
          theme[available_start]="#${palette.base0B}"
          theme[available_mid]="#${palette.base0A}"
          theme[available_end]="#${palette.base08}"

          # Mem/Disk used meter
          theme[used_start]="#${palette.base0B}"
          theme[used_mid]="#${palette.base0A}"
          theme[used_end]="#${palette.base08}"

          # Download graph colors
          theme[download_start]="#${palette.base0B}"
          theme[download_mid]="#${palette.base0A}"
          theme[download_end]="#${palette.base08}"

          # Upload graph colors
          theme[upload_start]="#${palette.base0B}"
          theme[upload_mid]="#${palette.base0A}"
          theme[upload_end]="#${palette.base08}"
        '';
      };
    };
  };
}
