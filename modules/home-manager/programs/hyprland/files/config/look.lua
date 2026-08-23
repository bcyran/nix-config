-- General look and feel: borders, groups, decoration, misc and per-layout
-- tweaks. Colors and fonts come from the Nix-generated data module so the
-- theme stays in sync with the rest of the desktop (see
-- config.generated / modules/home-manager/presets/tokyonight.nix).
local generated = require("config.generated")
local palette = generated.palette

local function rgb(hex)
  return "rgb(" .. hex .. ")"
end

local function rgba(hex, alpha)
  return "rgba(" .. hex .. alpha .. ")"
end

hl.config({
  general = {
    layout = "dwindle",
    gaps_in = 5,
    gaps_out = 10,
    border_size = 2,
    col = {
      active_border = rgb(palette.accentPrimary),
      inactive_border = rgb(palette.base10),
    },
  },

  ecosystem = {
    no_update_news = true,
    no_donation_nag = true,
  },

  group = {
    focus_removed_window = true,
    insert_after_current = true,
    col = {
      border_active = rgb(palette.accentPrimary),
      border_inactive = rgb(palette.base10),
    },
    groupbar = {
      enabled = true,
      font_family = generated.fontFamily,
      font_size = 12,
      render_titles = true,
      gradients = true,
      gradient_rounding = 3,
      indicator_height = 0,
      height = 22,
      rounding = 3,
      round_only_edges = false,
      text_padding = 8,
      text_color = rgba(palette.base10, "ed"),
      text_color_inactive = rgba(palette.base05, "ed"),
      col = {
        active = rgba(palette.accentPrimary, "ed"),
        inactive = rgba(palette.base10, "ed"),
      },
      gaps_in = 0,
      gaps_out = 0,
      keep_upper_gap = false,
    },
  },

  decoration = {
    rounding = 3,
    active_opacity = 0.93,
    inactive_opacity = 0.93,
    fullscreen_opacity = 1.0,
    shadow = {
      enabled = true,
      range = 20,
      render_power = 3,
      color = rgba(palette.base00, "cc"),
    },
    blur = {
      enabled = true,
      size = 5,
      passes = 2,
      new_optimizations = true,
      vibrancy = 0.1696,
      special = true,
    },
  },

  dwindle = {
    preserve_split = true,
    force_split = 2,
  },

  binds = {
    workspace_back_and_forth = true,
  },

  misc = {
    mouse_move_enables_dpms = true,
    key_press_enables_dpms = true,
    force_default_wallpaper = 0,
    animate_manual_resizes = true,
    focus_on_activate = true,
    disable_hyprland_guiutils_check = true,
    enable_swallow = true,
    swallow_regex = "^(kitty|terminal-floating|terminal-workspace)$",
  },

  cursor = {
    inactive_timeout = 60,
    hide_on_key_press = true,
    persistent_warps = true,
    warp_on_change_workspace = 1,
  },

  xwayland = {
    force_zero_scaling = true,
  },
})
