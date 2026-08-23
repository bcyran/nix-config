-- Environment variables applied before the Wayland display server starts.
-- Values are computed in Nix and shared with `home.sessionVariables`, so the
-- rest of the session sees the same variables as Hyprland itself. See
-- ../../default.nix for how `generated.env` is built.
local generated = require("config.generated")

for name, value in pairs(generated.env) do
  hl.env(name, value)
end
