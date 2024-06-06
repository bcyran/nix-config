{
  # Based on: https://github.com/folke/tokyonight.nvim
  colorScheme = {
    slug = "tokyo-night-moon";
    name = "Tokyo Night Moon";
    author = "Folke Lemaitre";
    palette = rec {
      # Terminal & CLI
      bg = "#222436";
      fg = "#c8d3f5";
      base00 = "#1b1d2b";
      base01 = "#ff757f";
      base02 = "#c3e88d";
      base03 = "#ffc777";
      base04 = "#82aaff";
      base05 = "#c099ff";
      base06 = "#86e1fc";
      base07 = "#828bb8";
      base08 = "#444a73";
      base09 = "#ff757f";
      base0A = "#c3e88d";
      base0B = "#ffc777";
      base0C = "#82aaff";
      base0D = "#c099ff";
      base0E = "#86e1fc";
      base0F = "#c8d3f5";

      # GUI
      guiBg = bg;
      guiBgDark = "#1e2030";
      guiBgHighlight = "#2f334d";
      guiFg = fg;
      guiFgDark = "#828bb8";
      guiAccentPrimary = base04;
      guiAccentSecondary = base02;
      guiWarning = base03;
      guiError = base01;
    };
  };
}
