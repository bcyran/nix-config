{
  # Based on: https://github.com/folke/tokyonight.nvim
  colorScheme = {
    slug = "tokyo-night-moon";
    name = "Tokyo Night Moon";
    author = "Folke Lemaitre";
    palette = rec {
      base00 = "#222436"; # Default background
      base01 = "#2f334d"; # Light background
      base02 = "#2d3f76"; # Selection background
      base03 = "#5d66a0"; # Comments
      base04 = "#828bb8"; # Dark foreground
      base05 = "#c8d3f5"; # Default foreground
      base06 = "#3760bf"; # Light foreground
      base07 = "#e1e2e7"; # Light background
      base08 = "#ff757f"; # Red; variables, XML Tags
      base09 = "#ff966c"; # Orange; integers, boolean, constants, XML attributes
      base0A = "#ffc777"; # Yellow; classes
      base0B = "#c3e88d"; # Green; strings
      base0C = "#4fd6be"; # Teal; regex, escape characters
      base0D = "#7aa2f7"; # Blue; functions, methods
      base0E = "#fca7ea"; # Magenta; keywords
      base0F = "#c53b53"; # Purple; deprecated, embedded language

      # GUI
      accentPrimary = base0D;
      accentSecondary = base0B;
      warning = base0A;
      error = base0F;

      # Legacy
      bg = "#222436";
      fg = "#c8d3f5";
      comment = "#565f89";
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
