{
  # Based on: https://github.com/folke/tokyonight.nvim
  colorScheme = {
    slug = "tokyo-night-moon";
    name = "Tokyo Night Moon";
    author = "Folke Lemaitre";
    palette = rec {
      # Base 16
      base00 = "#222436"; # Default background
      base01 = "#2f334d"; # Light background
      base02 = "#2d3f76"; # Selection background
      base03 = "#636da6"; # Comments
      base04 = "#828bb8"; # Dark foreground
      base05 = "#c8d3f5"; # Default foreground
      base06 = "#3760bf"; # Light foreground
      base07 = "#e1e2e7"; # Light background
      base08 = "#ff757f"; # Red; variables, XML Tags
      base09 = "#ff966c"; # Orange; integers, boolean, constants, XML attributes
      base0A = "#ffc777"; # Yellow; classes
      base0B = "#c3e88d"; # Green; strings
      base0C = "#4fd6be"; # Cyan; regex, escape characters
      base0D = "#82aaff"; # Blue; functions, methods
      base0E = "#fca7ea"; # Purple; keywords
      base0F = "#c53b53"; # Dark red / brown; deprecated, embedded language

      # Base 24 extensions
      base10 = "#1e2030"; # Darker background
      base11 = "#191b28"; # The darkest background
      base12 = base08; # Bright red
      base13 = base0A; # Bright yellow
      base14 = base0B; # Bright green
      base15 = base0C; # Bright cyan
      base16 = base0D; # Bright blue
      base17 = base0E; # Bright purple

      # Additional semantics
      accentPrimary = base0D;
      accentSecondary = base0B;
      warning = base0A;
      error = base0F;
    };
  };
}
